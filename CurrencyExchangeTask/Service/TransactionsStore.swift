//
//  TransactionsProvider.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation

// TODO: 
final class TransactionsStore: ObservableObject {

    @Storage(key: "AccountTransactions", defaultValue: [])
    private(set) var transactions: [AccountTransaction]

    func save(transaction: AccountTransaction) {
        transactions.append(transaction)
    }
}
