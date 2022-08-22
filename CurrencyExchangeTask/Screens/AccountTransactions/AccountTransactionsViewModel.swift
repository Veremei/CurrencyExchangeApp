//
//  AccountTransactionsViewModel.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation
import Combine

protocol AccountTransactionsViewModel: ObservableObject {
//    var accountsContentPublisher: Published<[BankAccount]>.Publisher { get }
}

final class AccountTransactionsDefaultViewModel: AccountTransactionsViewModel {

    @Published var transactions: [AccountTransaction] = []
//    var accountsContentPublisher: Published<[BankAccount]>.Publisher { $accountsContent }

    private let transactionsProvider: TransactionsProvider
    private var cancellables: Set<AnyCancellable> = []

    init() {
        transactionsProvider = TransactionsProvider()
        subscribe()
    }

    private func subscribe() {
        transactionsProvider.$transactions
            .sink(receiveValue: { [weak self] transactions in
                guard let self = self else { return }
                self.transactions = transactions
            })
            .store(in: &cancellables)
    }
}
