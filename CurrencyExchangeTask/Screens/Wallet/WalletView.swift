//
//  WalletView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 22.08.2022.
//

import SwiftUI

struct WalletView: View {

    @ObservedObject private var viewModel: WalletDefaultViewModel

    // TODO: configure view model
    init(viewModel: WalletDefaultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach($viewModel.accountsContent, id: \.self) { $account in
                    Text("\(String(format: "%.2f", account.accountValue)) \(account.currency.rawValue)")
                        .padding()
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(14)
                }
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = WalletDefaultViewModel()
        WalletView(viewModel: vm)
    }
}
