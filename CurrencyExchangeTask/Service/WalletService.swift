//
//  WalletService.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 20.08.2022.
//

import Foundation

protocol WalletServiceProtocol {
    var currenciesList: [Currency] { get }
    var currentValues: [Currency: Double] { get }

    func increase(with value: Double, id: Currency)
    func decrease(with value: Double, id: Currency)
}

final class WalletService: WalletServiceProtocol {
    static let shared = WalletService()
    private init() {}

    var currenciesList: [Currency] = [.EUR, .USD, .GBP]
    var currentValues: [Currency: Double] = [.USD: 1000, .EUR: 1000, .GBP: 0]


    func increase(with value: Double, id: Currency) {
        guard let val = currentValues[id] else { return }
        currentValues[id] = val + value
    }

    func decrease(with value: Double, id: Currency) {
        guard let val = currentValues[id] else { return }
        currentValues[id] = val - value
    }

}
