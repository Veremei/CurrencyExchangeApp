//
//  WalletService.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 20.08.2022.
//

import Foundation
import Combine

protocol WalletServiceProtocol: AnyObject {
    var accountsPublisher: Published<[String: BankAccount]>.Publisher { get }

    func ableToDecrease(value: Double, fee: Double, from account: Currency) -> Bool
    func exchangeOperation(from sellValue: Double,
                           from sellCurrency: Currency,
                           to receiveValue: Double,
                           to receiveCurrency: Currency,
                           fee: Double)
}

final class WalletService: WalletServiceProtocol, ObservableObject {
    init(existingAccounts: [String: BankAccount]) {
        accounts = existingAccounts
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

    func changeBalance(with value: Double, id: Currency, info: String) {
        guard let bankAccount = accounts[id.rawValue] else { return }
        accounts[id.rawValue]?.accountValue += value

        let transaction = AccountTransaction(bankAccount: bankAccount, value: value, info: info, date: Date())
        AppStorageData.transactions.append(transaction)
    }

    func exchangeOperation(from sellValue: Double,
                           from sellCurrency: Currency,
                           to receiveValue: Double,
                           to receiveCurrency: Currency,
                           fee: Double) {
        let transactionMessage = [sellCurrency.rawValue, receiveCurrency.rawValue].joined(separator: " to ")
        changeBalance(with: -sellValue, id: sellCurrency, info: transactionMessage)
        if fee > 0 {
            changeBalance(with: -fee, id: sellCurrency, info: "Fee")
        }
        changeBalance(with: receiveValue, id: receiveCurrency, info: transactionMessage)
    }
}
