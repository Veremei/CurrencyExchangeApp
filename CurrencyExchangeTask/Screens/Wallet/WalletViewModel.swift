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
                self.accountsContent = Array(accounts.values)
            })
            .store(in: &cancellables)
    }
}
