//
//  TransactionItemRow.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

struct TransactionItemRow: View {
    let item: AccountTransaction

    var body: some View {
        HStack {
            Text("\(item.value, specifier: "%.2f") \(item.bankAccount.currency.rawValue)")
            Spacer()
            Text(item.date, format: .dateTime)
        }
    }
}

struct TransactionItemRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionItemRow(item: .fakeSellTransaction)
    }
}
