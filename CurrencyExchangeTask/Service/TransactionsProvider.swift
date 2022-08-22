//
//  TransactionsProvider.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation

final class TransactionsProvider: ObservableObject {

    @Published var transactions: [AccountTransaction] = []

    init() {
        loadData()
    }

    private func loadData() {

    }
}
