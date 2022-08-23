//
//  CurrencyExchangeCoordinator.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

final class CurrencyExchangeCoordinator: CoordinatorProtocol {

    func build() -> AnyView {
//        let model = CurrencyExchangeDefaultViewModel()
        return CurrencyExchangeView().toAnyView()
    }
}
