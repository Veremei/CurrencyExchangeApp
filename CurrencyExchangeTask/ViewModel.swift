//
//  ViewModel.swift
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

final class ViewModel: ObservableObject {
    @Published var sellValue: String = "" {
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
    @Published var buyValue: String = ""

    @Published var selectedSellCurrency: Currency {
        didSet {
            updateCurrenciesState()
        }
    }

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

    /// Last update timestamp
    @Published var date: Date?

    @Published var sellCurrencies: [Currency] = []
    @Published var receiveCurrencies: [Currency] = []

    @Published var viewAlertContent: ViewAlertContent?
    @Published var presentingConvertAlert = false


    private let dateStyle: Date.FormatStyle = Date.FormatStyle().hour().minute().second()
    private let exchangeService = ExchangeRateService()

    private var allCurrencies: [Currency]
    private var currentRates: [Currency: Double] = [:]

    // TODO: https://developer.apple.com/documentation/combine/replacing-foundation-timers-with-timer-publishers
    private var timer: Timer?

    private var cancellable: Cancellable?


    init(allCurrencies: [Currency] = [.EUR, .USD, .GBP]) {
        self.allCurrencies = allCurrencies

        self.selectedSellCurrency = allCurrencies.first ?? .EUR
        self.selectedReceiveCurrency = allCurrencies.first ?? .EUR

        updateCurrenciesState()
    }

    func loadRates() {
        //        guard let selected = selectedSellCurrency else { return }
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

    func convert() {
        exchangeService.convert(amount: sellValue,
                                from: selectedSellCurrency,
                                to: selectedReceiveCurrency) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let response):
                let message = "You have converted \(self.sellValue) \(self.selectedSellCurrency.rawValue) to \(String(format: "%.2f", response.result)) \(self.selectedReceiveCurrency.rawValue)"
                self.viewAlertContent = ViewAlertContent(title: "Currency converted", message: message)
                self.presentingConvertAlert = true
            case .failure(let error):
                print(error)
            }

        }
    }

    private func updateCurrenciesState() {
        //        guard let selectedCurrency = selectedSellCurrency else {
        //            return
        //        }
        sellValue.removeAll()
        
        sellCurrencies = allCurrencies

        selectedReceiveCurrency = allCurrencies.first(where: { currency in
            currency != selectedSellCurrency
        }) ?? .USD

        receiveCurrencies = allCurrencies.filter { $0 != selectedSellCurrency }

        loadRates()
    }
    
}





