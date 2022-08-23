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
    func increase(with value: Double, id: Currency, info: String)
    func decrease(with value: Double, id: Currency, info: String)
}

final class WalletService: WalletServiceProtocol, ObservableObject {
    static let shared = WalletService()
    private init() {
        accounts = cachedAccounts
    }

    @Published private(set) var accounts: [String: BankAccount] = [:] {
        didSet {
            cachedAccounts = accounts
        }
    }
    var accountsPublisher: Published<[String: BankAccount]>.Publisher { $accounts }

    @Storage(key: "BankAccounts", defaultValue: BankAccount.fakeAccounts)
    var cachedAccounts: [String: BankAccount]

    func ableToDecrease(value: Double, fee: Double, from account: Currency) -> Bool {
        guard let val = accounts[account.rawValue]?.accountValue else { return false }
        return val - value - fee >= 0
    }

    func increase(with value: Double, id: Currency, info: String) {
        guard let bankAccount = accounts[id.rawValue] else { return }
        accounts[id.rawValue]?.accountValue += value

        let transaction = AccountTransaction(bankAccount: bankAccount, value: value, info: info, date: Date())
        AppStorageData.transactions.append(transaction)
    }

    func decrease(with value: Double, id: Currency, info: String) {
        guard let bankAccount = accounts[id.rawValue] else { return }
        accounts[id.rawValue]?.accountValue -= value

        let transaction = AccountTransaction(bankAccount: bankAccount, value: -value, info: info, date: Date())
        AppStorageData.transactions.append(transaction)
    }
}
