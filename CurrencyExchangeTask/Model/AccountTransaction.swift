//
//  AccountTransaction.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation

struct AccountTransaction: Identifiable, Codable {
    var id = UUID()
    let bankAccount: BankAccount
    let value: Double
    let date: Date
}

extension AccountTransaction {
    static let fakeSellTransaction = AccountTransaction(bankAccount: BankAccount(currency: .EUR, accountValue: 990, order: 0),
                                                    value: -10,
                                                    date: Date())

    static let fakeBuyTransaction = AccountTransaction(bankAccount: BankAccount(currency: .USD, accountValue: 10, order: 1),
                                                    value: 10,
                                                    date: Date())
}
