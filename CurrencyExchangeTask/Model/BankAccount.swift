//
//  BankAccount.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 21.08.2022.
//

import Foundation

struct BankAccount: Identifiable, Hashable, Equatable, Codable {
    #warning("change to unique")
    var id: String { currency.rawValue }
    let currency: Currency
    var accountValue: Double
    var order: Int
}

extension BankAccount {
    static let fakeAccount: BankAccount = BankAccount(currency: .EUR, accountValue: 1000, order: 0)

    static let fakeAccounts: [String: BankAccount] = [
        Currency.EUR.rawValue: BankAccount(currency: .EUR, accountValue: 1000, order: 0),
        Currency.USD.rawValue: BankAccount(currency: .USD, accountValue: 0, order: 1),
        Currency.GBP.rawValue: BankAccount(currency: .GBP, accountValue: 0, order: 2)]
}
