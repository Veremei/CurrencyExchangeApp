//
//  DashboardViewModel.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI
import Combine

enum DashboardViewModelAction {
    case account
}

typealias DashboardViewModelCallback = (DashboardViewModelAction) -> AnyView

protocol DashboardViewModel: ObservableObject {}

final class DashboardDefaultViewModel: DashboardViewModel {

    /// Sell field value.
    @Published var sellValue: String = ""

    /// Buy/Receive field value.
    @Published var buyValue: String = "0"

    /// Currently selected sell currency.
    @Published var selectedSellCurrency: Currency

    /// Currently selected receive(buy) currency.
    @Published var selectedReceiveCurrency: Currency

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

    private let exchangeService: ExchangeRateServiceProtocol
    private let accountService: WalletServiceProtocol

    private let callback: DashboardViewModelCallback

    // All available currencies.
    private var allCurrencies: [Currency]

    // Last exchange rates. TODO: move to service?
    private var currentRates: [Currency: Double] = [:]

    private var timer: Timer?
    private var cancellables: Set<AnyCancellable> = []

    private var equivalentRate: Double {
        currentRates[.EUR] ?? 1
    }

    init(allCurrencies: [Currency] = Currency.defaultList,
         exchangeService: ExchangeRateServiceProtocol = ServicesRepository.shared.exchangeRateService,
         accountService: WalletServiceProtocol = ServicesRepository.shared.walletService,
         callback: @escaping DashboardViewModelCallback) {
        self.allCurrencies = allCurrencies
        self.selectedSellCurrency = allCurrencies.first ?? .EUR
        self.selectedReceiveCurrency = allCurrencies.first ?? .EUR
        self.exchangeService = exchangeService
        self.accountService = accountService
        self.callback = callback

        subscribe()
    }

    func buildAccount() -> AnyView {
        callback(.account)
    }

    private func subscribe() {
        accountService.accountsPublisher
            .sink(receiveValue: { [weak self] accounts in
                guard let self = self else { return }
                self.accountsContent = Array(accounts.values)
            })
            .store(in: &cancellables)

        $sellValue.sink { [weak self] value in
            guard let self = self else {
                return
            }

            guard !value.isEmpty, let buyDoubleValue = Double(value), buyDoubleValue > 0 else {
                self.ableToConvert = false
                self.buyValue = "0"
                return
            }

            guard let rateConversion = self.currentRates[self.selectedReceiveCurrency] else {
                self.showAlert(title: "Error", message: "Current exchange rates are not available")
                return
            }

            guard self.accountService.ableToDecrease(value: buyDoubleValue,
                                                     fee: self.exchangeService.getFee(amount: buyDoubleValue, for: self.selectedSellCurrency, feeRate: self.equivalentRate),
                                                     from: self.selectedSellCurrency) else {
                self.ableToConvert = false
                self.buyValue = "0"
                self.showAlert(title: "Wrong input value", message: "Check your account balance")
                return
            }
            self.ableToConvert = true
            let finalValue = rateConversion * buyDoubleValue
            self.buyValue = String(format: "%.2f", finalValue)
        }
        .store(in: &cancellables)

        $selectedSellCurrency
            .sink(receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.updateCurrenciesState()
            })
            .store(in: &cancellables)

        $selectedReceiveCurrency
            .sink(receiveValue: { [weak self] value in
                guard let self = self else { return }
                guard let buyIntValue = Double(self.sellValue),
                      let rateConversion = self.currentRates[value] else {
                    // TODO: return Alert "wrong input value"
                    self.buyValue.removeAll()
                    return }
                let finalValue = rateConversion * buyIntValue
                self.buyValue = String(format: "%.2f", finalValue)
            })
            .store(in: &cancellables)
    }

    func loadRates() {
        exchangeService.loadRates(for: selectedSellCurrency, with: receiveCurrencies)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                case .finished:
                    return
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }

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
            })
            .store(in: &cancellables)
    }

    /// Convert current sell field value
    func convert() {
        guard let sellDoubleValue = Double(sellValue) else { return }
        exchangeService.convert(amount: sellValue,
                                from: selectedSellCurrency,
                                to: selectedReceiveCurrency)
        .sink(receiveCompletion: { [weak self] result in
            switch result {
            case .failure(let error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            case .finished:
                return
            }
        }, receiveValue: { [weak self] response in
            guard let self = self else { return }
            let updatedFee = self.exchangeService.getFee(amount: sellDoubleValue, for: self.selectedSellCurrency, feeRate: self.equivalentRate)

            guard self.accountService.ableToDecrease(value: sellDoubleValue, fee: updatedFee, from: self.selectedSellCurrency) else {
                self.showAlert(title: "Insufficient funds", message: "The balance can't fall below zero")
                return
            }

            self.accountService.exchangeOperation(from: sellDoubleValue,
                                                  from: self.selectedSellCurrency,
                                                  to: response.result,
                                                  to: self.selectedReceiveCurrency,
                                                  fee: updatedFee)

            let feeMessage = updatedFee > 0 ? "Commission Fee - \(String(format: "%.2f", updatedFee)) \(self.selectedSellCurrency.rawValue)." : ""
            let message = ["You have converted \(self.sellValue) \(self.selectedSellCurrency.rawValue) to \(String(format: "%.2f", response.result)) \(self.selectedReceiveCurrency.rawValue).", feeMessage].joined(separator: " ")
            self.showAlert(title: "Currency converted", message: message)
            self.reset()
        })
        .store(in: &cancellables)
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

    private func showAlert(title: String, message: String) {
        viewAlertContent = ViewAlertContent(title: title, message: message)
        presentingAlert = true
    }

    private func reset() {
        sellValue = "0"
        buyValue = "0"
        ableToConvert = false
    }
}

