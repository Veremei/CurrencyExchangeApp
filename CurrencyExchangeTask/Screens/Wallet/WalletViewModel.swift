//
//  WalletViewModel.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 22.08.2022.
//

import Foundation
import Combine

protocol WalletViewModel: ObservableObject {
    var accountsContentPublisher: Published<[BankAccount]>.Publisher { get }
}

final class WalletDefaultViewModel: WalletViewModel {

    @Published var accountsContent: [BankAccount] = []
    @Published var presentingTransactions = false
    @Published var presentingTransactionsBankAccount: BankAccount? {
        didSet {
            if let _ = presentingTransactionsBankAccount {
                presentingTransactions = true
            }
        }
    }

    var accountsContentPublisher: Published<[BankAccount]>.Publisher { $accountsContent }

    private let accountService: WalletServiceProtocol = WalletService.shared
    private var cancellables: Set<AnyCancellable> = []

    init() {
        subscribe()
    }

    private func subscribe() {
        accountService.accountsPublisher
            .sink(receiveValue: { [weak self] accounts in
                guard let self = self else { return }
                self.accountsContent = Array(accounts.values).sorted(by: { $0.order < $1.order })
            })
            .store(in: &cancellables)
    }
}
