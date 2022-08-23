//
//  BankAccountCoordinator.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

final class BankAccountCoordinator: CoordinatorProtocol {
    
    func build() -> AnyView {
        let model = BankAccountDefaultViewModel(accountService: ServicesRepository.shared.walletService)
        return BankAccountView(viewModel: model).toAnyView()
    }
}
