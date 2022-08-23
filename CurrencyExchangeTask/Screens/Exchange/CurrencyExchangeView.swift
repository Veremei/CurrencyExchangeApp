////
////  CurrencyExchangeView.swift
////  CurrencyExchangeTask
////
////  Created by Daniil Veramei on 23.08.2022.
////
//
//import SwiftUI
//
//struct CurrencyExchangeView: View {
//    private struct Constants {
//        // TODO: move to asset colors / app color scheme
//        static let color = Color(red: 0.102, green: 0.057, blue: 0.196)
//        static let secondaryColor = Color(red: 0.162, green: 0.134, blue: 0.251)
//    }
//
//    @Binding var sellValue: String
//    @Binding var buyValue: String
//
//    /// List of currencies available for the sell picker.
//    @Binding var sellCurrencies: [Currency]
//
//    /// List of currencies available for the receive(buy) picker.
//    @Binding var receiveCurrencies: [Currency]
//
//    var body: some View {
//        // Sell
//        HStack {
//            Image(systemName: "arrow.up.circle.fill")
//                .foregroundColor(.red)
//            Text("Sell")
//                .foregroundColor(.white)
//            Spacer()
//            // Sell input
//
//            TextField("",
//                      text: sellValue)
//            .modifier(PlaceholderStyle(showPlaceHolder: sellValue.isEmpty, placeholder: "0.00", alignment: .trailing))
//            .foregroundColor(.white)
//            .multilineTextAlignment(.trailing)
//            .keyboardType(.decimalPad)
//            .frame(width: 100)
//
//            if !sellCurrencies.isEmpty {
//                Divider()
//                Picker(selection: $selectedSellCurrency, label: Text("Picker")) {
//                    ForEach(sellCurrencies, id: \.self) { val in
//                        Text(val.rawValue).tag(val)
//                    }
//                }
//                .frame(width: 40)
//                .id(0)
//            }
//        }
//        .fixedSize(horizontal: false, vertical: true)
//        .padding()
//        .background(Constants.secondaryColor)
//        .cornerRadius(10)
//
//
//        Divider()
//
//        // Recieve
//        HStack {
//            Image(systemName: "arrow.down.circle.fill")
//                .foregroundColor(.green)
//            Text("Recieve")
//                .foregroundColor(.white)
//            Spacer()
//            // Recieve input
//            TextField("", text: buyValue)
//                .modifier(PlaceholderStyle(showPlaceHolder: buyValue.isEmpty, placeholder: "0.00", alignment: .trailing))
//                .foregroundColor(.white)
//                .multilineTextAlignment(.trailing)
//                .keyboardType(.decimalPad)
//                .frame(width: 100)
//
//            if !receiveCurrencies.isEmpty {
//                Divider()
//
//                Picker(selection: $selectedReceiveCurrency, label: Text("Picker")) {
//                    ForEach(viewModel.receiveCurrencies, id: \.self) { val in
//                        Text(val.rawValue).tag(val)
//                    }
//                }
//                .frame(width: 40)
//                .id(1)
//            }
//        }
//        .fixedSize(horizontal: false, vertical: true)
//        .padding()
//        .background(Constants.secondaryColor)
//        .cornerRadius(10)
//    }
//}
//
//struct CurrencyExchangeView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrencyExchangeView()
//    }
//}
