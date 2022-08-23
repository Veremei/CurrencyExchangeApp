//
//  ContentView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import SwiftUI

struct MainContentView: View {
    private struct Constants {
        // TODO: move to asset colors / app color scheme
        static let color = Color(red: 0.102, green: 0.057, blue: 0.196)
        static let secondaryColor = Color(red: 0.162, green: 0.134, blue: 0.251)

        static let buttonHorizontalPadding: CGFloat = 24
    }

    @ObservedObject private var viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        viewModel.buildDashboard()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = MainViewModel(callback: { _ in
            return AnyView.defaultError })
        MainContentView(viewModel: vm)
    }
}
