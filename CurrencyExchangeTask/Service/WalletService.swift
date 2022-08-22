//
//  WalletService.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 20.08.2022.
//

import Foundation
import Combine

protocol WalletServiceProtocol {
    var accountsPublisher: Published<[String: BankAccount]>.Publisher { get }

    func ableToDecrease(value: Double, fee: Double, from account: Currency) -> Bool
    func increase(with value: Double, id: Currency)
    func decrease(with value: Double, id: Currency)
}

final class WalletService: WalletServiceProtocol, ObservableObject {
    static let shared = WalletService()
    private init() {}

    @Published private(set) var accounts: [String: BankAccount] = BankAccount.fakeAccounts
    var accountsPublisher: Published<[String: BankAccount]>.Publisher { $accounts }

    func ableToDecrease(value: Double, fee: Double, from account: Currency) -> Bool {
        guard let val = accounts[account.rawValue]?.accountValue else { return false }
        return val - value - fee >= 0
    }

    func increase(with value: Double, id: Currency) {
        guard let val = accounts[id.rawValue]?.accountValue else { return }
        accounts[id.rawValue]?.accountValue = val + value
    }

    func decrease(with value: Double, id: Currency) {
        guard let val = accounts[id.rawValue]?.accountValue else { return }
        accounts[id.rawValue]?.accountValue = val - value
    }
}
