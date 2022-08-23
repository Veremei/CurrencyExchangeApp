//
//  WalletView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 22.08.2022.
//

import SwiftUI

struct WalletView: View {
    private struct Constants {
        // TODO: move to asset colors / app color scheme
        static let color = Color(red: 0.102, green: 0.057, blue: 0.196)
        static let secondaryColor = Color(red: 0.162, green: 0.134, blue: 0.251)
    }
    
    @ObservedObject private var viewModel: WalletDefaultViewModel

    // TODO: configure view model
    init(viewModel: WalletDefaultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach($viewModel.accountsContent, id: \.self) { $account in
                    WalletAccountView(account: account)
                    .onTapGesture {
                        viewModel.presentingTransactionsBankAccount = account
                    }
                }
            }
            .sheet(isPresented: $viewModel.presentingTransactions,
                   content: {
                AccountTransactionsView(viewModel:
                                            AccountTransactionsDefaultViewModel(account: viewModel.presentingTransactionsBankAccount))
            })
        }
    }

    
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = WalletDefaultViewModel()
        WalletView(viewModel: vm)
    }
}
