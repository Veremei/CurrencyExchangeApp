//
//  CurrencyExchangeTaskApp.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import SwiftUI

@main
struct CurrencyExchangeTaskApp: App {
    let mainCoordinator = MainContentCoordinator()

    var body: some Scene {
        WindowGroup {
            mainCoordinator.build()
        }
    }
}
