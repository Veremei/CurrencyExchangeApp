//
//  MainContentCoordinator.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

protocol CoordinatorProtocol: AnyObject {
    func build() -> AnyView
}

final class MainContentCoordinator: CoordinatorProtocol {
    let dashboardCoordinator = DashboardCoordinator()

    private lazy var viewModel = MainViewModel { [weak self] action in
        guard let self = self else {
            return AnyView.defaultError
        }

        switch action {
        case .dashboard:
            return self.buildDashboard()
        }
    }

    func build() -> AnyView {
        MainContentView(viewModel: viewModel).toAnyView()
    }

    func buildDashboard() -> AnyView {
        dashboardCoordinator.build()
    }
}
