//
//  MainViewModel.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import Foundation
import Combine

protocol SomeViewModel {
    func exchange()
}

final class MainViewModel: ObservableObject {

    private var equivalentRate: Double {
        currentRates[.EUR] ?? 1
    }

    /// Sell field value.
    @Published var sellValue: String = "" {
        // TODO: move to separate calc value
        didSet {
            guard !sellValue.isEmpty, let buyDoubleValue = Double(sellValue), buyDoubleValue > 0 else {
                ableToConvert = false
                buyValue = "0"
                return
            }

            guard let rateConversion = currentRates[selectedReceiveCurrency],
                  accountService.ableToDecrease(value: buyDoubleValue,
                                                fee: exchangeService.getFee(amount: buyDoubleValue, for: selectedSellCurrency, feeRate: equivalentRate),
                                                from: selectedSellCurrency) else {
                ableToConvert = false
                viewAlertContent = ViewAlertContent(title: "Wrong input value", message: "Check your input value")
                presentingAlert = true
                buyValue = "0"
                return
            }
            ableToConvert = true
            let finalValue = rateConversion * buyDoubleValue
            buyValue = String(format: "%.2f", finalValue)
        }
    }

    /// Buy/Receive field value.
    @Published var buyValue: String = "0"

    /// Currently selected sell currency.
    @Published var selectedSellCurrency: Currency {
        didSet {
            updateCurrenciesState()
        }
    }

    /// Currently selected receive(buy) currency.
    @Published var selectedReceiveCurrency: Currency {
        didSet {
            guard let buyIntValue = Double(sellValue),
                  let rateConversion = currentRates[selectedReceiveCurrency] else {
                // TODO: return Alert "wrong input value"
                buyValue.removeAll()
                return }
            let finalValue = rateConversion * buyIntValue
            buyValue = String(format: "%.2f", finalValue)
        }
    }

    @Published var accountsContent: [BankAccount] = []

    /// Last update timestamp.
    @Published private(set) var date: Date?

    /// List of currencies available for the sell picker.
    @Published private(set) var sellCurrencies: [Currency] = []

    /// List of currencies available for the receive(buy) picker.
    @Published private(set) var receiveCurrencies: [Currency] = []

    @Published var viewAlertContent: ViewAlertContent?
    @Published var presentingAlert = false

    @Published var presentingTransactions = false
    @Published var presentingTransactionsBankAccount: BankAccount?

    @Published var ableToConvert = false


    let dateStyle: Date.FormatStyle = Date.FormatStyle().hour().minute().second()
    let walletModel = WalletDefaultViewModel()

    private let exchangeService: ExchangeRateServiceProtocol = ExchangeRateServiceMock()
    private let accountService: WalletServiceProtocol = WalletService.shared

    // All available currencies.
    private var allCurrencies: [Currency]

    // Last exchange rates. TODO: move to service?
    private var currentRates: [Currency: Double] = [:]

    // TODO: https://developer.apple.com/documentation/combine/replacing-foundation-timers-with-timer-publishers
    private var timer: Timer?
    private var cancellables: Set<AnyCancellable> = []

    init(allCurrencies: [Currency] = [.EUR, .USD, .GBP]) {
        self.allCurrencies = allCurrencies

        self.selectedSellCurrency = allCurrencies.first ?? .EUR
        self.selectedReceiveCurrency = allCurrencies.first ?? .EUR

        updateCurrenciesState()

//        self.sellValue = "0"
        subscribe()
    }

    private func subscribe() {
        accountService.accountsPublisher
            .sink(receiveValue: { [weak self] accounts in
                guard let self = self else { return }
                self.accountsContent = Array(accounts.values)
            })
            .store(in: &cancellables)
    }

    func loadRates() {
        exchangeService.loadRates(for: selectedSellCurrency, with: receiveCurrencies) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    print(response)

                    if let timestamp = response.timestamp {
                        self.date = Date(timeIntervalSince1970: timestamp)
                    } else {
                        self.date = Date()
                    }

                    for (key, value) in response.rates {
                        guard let currencyKey = Currency(rawValue: key) else {
                            continue
                        }
                        self.currentRates[currencyKey] = value
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    /// Convert current sell field value
    func convert() {
        guard let sellDoubleValue = Double(sellValue) else { return }
        exchangeService.convert(amount: sellValue,
                                from: selectedSellCurrency,
                                to: selectedReceiveCurrency) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let response):

                #warning("dirty")
                let updatedFee = self.exchangeService.getFee(amount: sellDoubleValue, for: self.selectedSellCurrency, feeRate: self.equivalentRate)

                guard self.accountService.ableToDecrease(value: sellDoubleValue, fee: updatedFee, from: self.selectedSellCurrency) else {
                    self.viewAlertContent = ViewAlertContent(title: "Insufficient funds", message: "the balance can't fall below zero")
                    self.presentingAlert = true
                    return
                }

                let feeMessage = updatedFee > 0 ? "Commission Fee - \(String(format: "%.2f", updatedFee)) \(self.selectedSellCurrency.rawValue)." : ""
                let message = ["You have converted \(self.sellValue) \(self.selectedSellCurrency.rawValue) to \(String(format: "%.2f", response.result)) \(self.selectedReceiveCurrency.rawValue).", feeMessage].joined(separator: " ")

                // TODO: optimise ->
                #warning("optimise")
                self.accountService.decrease(with: sellDoubleValue, id: self.selectedSellCurrency, info: "\(self.selectedSellCurrency) to \(self.selectedReceiveCurrency)")
                if updatedFee > 0 {
                    self.accountService.decrease(with: updatedFee, id: self.selectedSellCurrency, info: "Fee")
                }
                self.accountService.increase(with: response.result, id: self.selectedReceiveCurrency, info: "\(self.selectedSellCurrency) to \(self.selectedReceiveCurrency)")

                self.reset()
                self.viewAlertContent = ViewAlertContent(title: "Currency converted", message: message)
                self.presentingAlert = true
            case .failure(let error):
                // TODO: Alert
                print(error)
            }
        }
    }

    private func updateCurrenciesState() {
        sellValue.removeAll()
        
        sellCurrencies = allCurrencies

        selectedReceiveCurrency = allCurrencies.first(where: { currency in
            currency != selectedSellCurrency
        }) ?? .USD

        receiveCurrencies = allCurrencies.filter { $0 != selectedSellCurrency }

        loadRates()
    }

    private func reset() {
        sellValue = "0"
        buyValue = "0"
    }
}
