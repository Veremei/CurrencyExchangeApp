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
    let from: AccountTransactionInfo
    let to: AccountTransactionInfo
    let date: Date
}

struct AccountTransactionInfo: Codable {
    let currency: Currency
    let value: Double
}
