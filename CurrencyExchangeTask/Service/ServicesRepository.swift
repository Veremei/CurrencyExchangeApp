//
//  ServicesRepository.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation

final class ServicesRepository {
    static let shared = ServicesRepository()
    
    private(set) var exchangeRateService: ExchangeRateServiceProtocol
    private(set) var walletService: WalletServiceProtocol


    private init() {
        let networkService = NetworkService.shared

        walletService = WalletService(existingAccounts: AppStorageData.bankAccounts)
        // use ExchangeRateService fake when "You have exceeded your daily..."
        exchangeRateService = ExchangeRateService(networkService: networkService, walletService: walletService)
    }

}
