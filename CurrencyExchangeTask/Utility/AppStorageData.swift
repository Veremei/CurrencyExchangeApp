//
//  AppStorageData.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation

struct AppStorageData {
    @Storage(key: "AccountTransactions", defaultValue: [])
    static var transactions: [AccountTransaction]

    @Storage(key: "BankAccounts", defaultValue: BankAccount.fakeAccounts)
    static var bankAccounts: [String: BankAccount]
}
