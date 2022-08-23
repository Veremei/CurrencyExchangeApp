//
//  BankAccountViewModel.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 22.08.2022.
//

import Foundation
import Combine

protocol BankAccountViewModel: ObservableObject {
    var accountsContentPublisher: Published<[BankAccount]>.Publisher { get }
}

final class BankAccountDefaultViewModel: BankAccountViewModel {

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

    private let accountService: WalletServiceProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(accountService: WalletServiceProtocol = ServicesRepository.shared.walletService) {
        self.accountService = accountService
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
