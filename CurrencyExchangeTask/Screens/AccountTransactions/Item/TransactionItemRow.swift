//
//  TransactionItemRow.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

struct TransactionItemRow: View {
    private struct Constants {
        // TODO: move to asset colors / app color scheme
        static let color = Color(red: 0.102, green: 0.057, blue: 0.196)
        static let secondaryColor = Color(red: 0.162, green: 0.134, blue: 0.251)
    }
    
    let item: AccountTransaction

    var body: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.date, format: .dateTime.year().month().day())
                    .font(.callout)
                    .foregroundColor(.gray)
                Text(item.info)
                    .font(.body)
                    .foregroundColor(.white)
                
            }
            Spacer()
            // TODO: Create formatter
            Text("\(item.value, specifier: "%.2f") \(item.bankAccount.currency.rawValue.currencyCodeSymbol ?? "")")
                .font(.title3)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(red: 0.22, green: 0.197, blue: 0.301))
        .cornerRadius(10)
    }
}

struct TransactionItemRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionItemRow(item: .fakeSellTransaction)

    }
}
