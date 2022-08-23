//
//  AccountTransactionsView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

struct AccountTransactionsView: View {
    private struct Constants {
        // TODO: move to asset colors / app color scheme
        static let color = Color(red: 0.102, green: 0.057, blue: 0.196)
        static let secondaryColor = Color(red: 0.162, green: 0.134, blue: 0.251)
    }

    @ObservedObject private var viewModel: AccountTransactionsDefaultViewModel

    init(viewModel: AccountTransactionsDefaultViewModel) {
        self.viewModel = viewModel
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }


    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(viewModel.transactions, id: \.self) { row in
                        TransactionItemRow(item: row)
                        Divider()
                    }
                }
            }
            .padding()
            .navigationTitle(Text("Transactions"))
            .navigationBarTitleDisplayMode(.large)
            .background(Constants.color.edgesIgnoringSafeArea(.all))
        }
    }
}

struct AccountTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AccountTransactionsDefaultViewModel(account: .fakeAccount)
        AccountTransactionsView(viewModel: vm)
    }
}
