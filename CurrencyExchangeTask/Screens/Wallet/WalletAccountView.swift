//
//  WalletAccountView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

struct WalletAccountView: View {
    private struct Constants {
        // TODO: move to asset colors / app color scheme
        static let color = Color(red: 0.102, green: 0.057, blue: 0.196)
        static let secondaryColor = Color(red: 0.162, green: 0.134, blue: 0.251)
    }

    let account: BankAccount

    var body: some View {
        let symbol = account.currency.rawValue.currencyCodeSymbol ?? ""
        VStack(alignment: .leading, spacing: 4){
            Text("\(account.currency.rawValue)")
                .font(.footnote)
                .foregroundColor(.white)

            Text("\(symbol) ")
                .font(.title2)
                .foregroundColor(.white)
            + Text("\(String(format: "%.2f", account.accountValue))")
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding()
        .frame(minWidth: 100)
        .background(Constants.secondaryColor)
        .cornerRadius(14)
    }
}

struct WalletAccountView_Previews: PreviewProvider {
    static var previews: some View {
        WalletAccountView(account: .fakeAccount)
    }
}
