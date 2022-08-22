//
//  MainViewModel.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import Foundation
import Combine

struct ViewAlertContent: Identifiable {
    var id: String { title }
    let title: String
    let message: String
}

protocol SomeViewModel {
    func exchange()
}

final class MainViewModel: ObservableObject {

    private var equivalentRate: Double {
        currentRates[.EUR] ?? 1
    }

    /// Sell field value.
    @Published var sellValue: String = "" {
        didSet {
            guard let buyIntValue = Double(sellValue),
                  let rateConversion = currentRates[selectedReceiveCurrency],
                  accountService.ableToDecrease(value: buyIntValue,
                                                fee: exchangeService.getFee(amount: buyIntValue, for: selectedSellCurrency, feeRate: equivalentRate),
                                                from: selectedSellCurrency) else {
                ableToConvert = false
                // TODO: return Alert "wrong input value"
                buyValue.removeAll()
                return }
            ableToConvert = true
            let finalValue = rateConversion * buyIntValue
            buyValue = String(format: "%.2f", finalValue)
        }
    }

    /// Buy/Receive field value.
    @Published var buyValue: String = ""

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
    @Published var presentingConvertAlert = false
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
//        guard accountService.ableToDecrease(value: sellDoubleValue, with: fee, from: selectedSellCurrency) else {
//            // - TODO: Alert insufficient funds...
//            // - TODO: move to text field check
//          the balance can't fall below zero
//            return
//        }

        guard let sellDoubleValue = Double(sellValue) else { return }
//        let fee = exchangeService.getFee(amount: sellDoubleValue, for: selectedSellCurrency, rate: 1)


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
                    // TODO: Alert insufficient funds...
                    #warning("Alert")
                    //                    the balance can't fall below zero
                    return
                }

                let feeMessage = updatedFee > 0 ? "Commission Fee - \(String(format: "%.2f", updatedFee)) \(self.selectedSellCurrency.rawValue)." : ""
                let message = ["You have converted \(self.sellValue) \(self.selectedSellCurrency.rawValue) to \(String(format: "%.2f", response.result)) \(self.selectedReceiveCurrency.rawValue).", feeMessage].joined(separator: " ")

                // TODO: optimise ->
                #warning("optimise")
                self.accountService.decrease(with: sellDoubleValue, id: self.selectedSellCurrency)
                self.accountService.increase(with: response.result, id: self.selectedReceiveCurrency)

                self.viewAlertContent = ViewAlertContent(title: "Currency converted", message: message)
                self.presentingConvertAlert = true
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
}
