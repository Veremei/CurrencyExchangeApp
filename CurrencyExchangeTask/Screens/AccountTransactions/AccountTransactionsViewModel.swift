//
//  AccountTransactionsViewModel.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation
import Combine

protocol AccountTransactionsViewModel: ObservableObject {
}

final class AccountTransactionsDefaultViewModel: AccountTransactionsViewModel {

    private(set) var transactions: [AccountTransaction] = []

//    private let transactionsProvider: TransactionsStoreProtocol

    init(account: BankAccount?) {
        guard let account = account else {
            return
        }

        self.transactions = AppStorageData.transactions
            .filter { $0.bankAccount.id == account.id }
            .sorted(by: { $0.date > $1.date })
    }
}
