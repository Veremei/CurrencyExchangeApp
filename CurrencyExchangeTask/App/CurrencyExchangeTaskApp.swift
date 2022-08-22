//
//  CurrencyExchangeTaskApp.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import SwiftUI

@main
struct CurrencyExchangeTaskApp: App {
    let vm = MainViewModel()
    var body: some Scene {
        WindowGroup {
            MainContentView(viewModel: vm)
        }
    }
}
