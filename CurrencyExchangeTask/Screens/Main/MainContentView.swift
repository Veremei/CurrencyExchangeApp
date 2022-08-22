//
//  ContentView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import SwiftUI

struct MainContentView: View {

    @ObservedObject private var viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {

                // Wallet
                VStack(alignment: .leading, spacing: 24) {
                    Text("My balances")
                        .textCase(.uppercase)

                    // TODO: configure view
                    WalletView(viewModel: viewModel.walletModel)
                        .frame(height: 40)
                }
                
                VStack {
                    HStack {
                        Text("Currency exchange")
                            .textCase(.uppercase)
                        Spacer()

                        // Last update timestamp
                        if let date = viewModel.date {
                            Text(date, format: viewModel.dateStyle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    // Sell
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.red)
                        Text("Sell")

                        // Sell input
                        TextField("Sell value", text: $viewModel.sellValue)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                        
                        if !viewModel.sellCurrencies.isEmpty {
                            Divider()
                            Picker(selection: $viewModel.selectedSellCurrency, label: Text("Picker")) {
                                ForEach(viewModel.sellCurrencies, id: \.self) { val in
                                    Text(val.rawValue).tag(val)
                                }
                            }
                            .frame(width: 40)
                            .id(0)
                        }
                    }.fixedSize(horizontal: false, vertical: true)


                    Divider()

                    // Recieve
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                        Text("Recieve")

                        // Recieve input
                        TextField("Recieve value", text: $viewModel.buyValue)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)

                        if !viewModel.receiveCurrencies.isEmpty {
                            Divider()
                            Picker(selection: $viewModel.selectedReceiveCurrency, label: Text("Picker")) {
                                ForEach(viewModel.receiveCurrencies, id: \.self) { val in
                                    Text(val.rawValue).tag(val)
                                }
                            }
                            .frame(width: 40)
                            .id(1)
                        }
                    }.fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Button {
                    viewModel.convert()
                } label: {
                    Text("Submit")
                        .textCase(.uppercase)
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .clipShape(Capsule())
                }
                .disabled(!viewModel.ableToConvert)
                .padding(.horizontal, 24)
            }
            .padding()
            .alert(viewModel.viewAlertContent?.title ?? "Done",
                   isPresented: $viewModel.presentingConvertAlert,
                   presenting: $viewModel.viewAlertContent,
                   actions: { _ in
                Button("OK", action: {})
            }, message: { _ in
                Text(viewModel.viewAlertContent?.message ?? "")
            })
            .navigationTitle("Currency converter")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = MainViewModel()
        MainContentView(viewModel: vm)
    }
}
