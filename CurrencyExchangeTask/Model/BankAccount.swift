//
//  BankAccount.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 21.08.2022.
//

import Foundation

struct BankAccount: Identifiable, Hashable, Equatable, Codable {
    var id: String { currency.rawValue }
    let currency: Currency
    var accountValue: Double
}

extension BankAccount {
    static let fakeAccounts: [String: BankAccount] = [
        Currency.EUR.rawValue: BankAccount(currency: .EUR, accountValue: 1000),
        Currency.USD.rawValue: BankAccount(currency: .USD, accountValue: 0),
        Currency.GBP.rawValue: BankAccount(currency: .GBP, accountValue: 0)]
}
