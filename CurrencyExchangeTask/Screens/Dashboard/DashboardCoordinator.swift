//
//  DashboardCoordinator.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

final class DashboardCoordinator: CoordinatorProtocol {

    private lazy var viewModel = DashboardDefaultViewModel(allCurrencies: Currency.defaultList,
                                                           exchangeService: ServicesRepository.shared.exchangeRateService,
                                                           accountService: ServicesRepository.shared.walletService) { [weak self] action in
        guard let self = self else {
            return AnyView.defaultError
        }

        switch action {
        case .account:
            return self.buildAccounts()
        }
    }

    func build() -> AnyView {
        return DashboardView(viewModel: viewModel).toAnyView()
    }

    func buildAccounts() -> AnyView {
        BankAccountCoordinator().build()
    }
}
