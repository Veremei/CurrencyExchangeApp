//
//  ContentView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var val: String = ""
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {

                // Wallet
                VStack(alignment: .leading, spacing: 24) {
                    Text("My balances")
                        .textCase(.uppercase)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(0...3, id: \.self) { index in
                                Text("10000 EUR")
                                    .onAppear {
                                        print(index)
                                    }
                            }
                        }
                    }.frame(height: 40)
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
        let vm = ViewModel()
        ContentView(viewModel: vm)
    }
}
