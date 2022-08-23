//
//  MainViewModel.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import SwiftUI
import Combine

enum MainViewModelAction {
    case dashboard
}

typealias MainViewModelCallback = (MainViewModelAction) -> AnyView

final class MainViewModel: ObservableObject {

    private let callback: MainViewModelCallback

    init(callback: @escaping MainViewModelCallback) {
        self.callback = callback
    }

    func buildDashboard() -> AnyView {
        callback(.dashboard)
    }
}
