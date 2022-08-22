//
//  AccountTransactionsView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

struct AccountTransactionsView: View {
    @ObservedObject private var viewModel: AccountTransactionsDefaultViewModel

    init(viewModel: AccountTransactionsDefaultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text("")
    }
}

struct AccountTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTransactionsView(viewModel: AccountTransactionsDefaultViewModel())
    }
}
