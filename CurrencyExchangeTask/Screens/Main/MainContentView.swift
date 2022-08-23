//
//  ContentView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import SwiftUI

struct MainContentView: View {
    private struct Constants {
        // TODO: move to asset colors / app color scheme
        static let color = Color(red: 0.102, green: 0.057, blue: 0.196)
        static let secondaryColor = Color(red: 0.162, green: 0.134, blue: 0.251)

        static let buttonHorizontalPadding: CGFloat = 24
    }

    @ObservedObject private var viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {

                // Wallet
                VStack(alignment: .leading, spacing: 8) {
                    Text("My balances")
                        .font(.body)
                        .textCase(.uppercase)
                        .foregroundColor(.white)

                    // TODO: configure view model
                    WalletView(viewModel: viewModel.walletModel)
                        .onTapGesture(perform: {
                            viewModel.presentingTransactions = true
                        })
                        .frame(height: 100)
                }
                
                VStack {
                    HStack(alignment: .bottom) {
                        Text("Currency exchange")
                            .font(.body)
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                        Spacer()

                        // Last update timestamp
                        if let date = viewModel.date {
                            Text(date, format: viewModel.dateStyle)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    // Sell
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.red)
                        Text("Sell")
                            .foregroundColor(.white)
                        Spacer()
                        // Sell input

                        TextField("",
                                  text: $viewModel.sellValue)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.sellValue.isEmpty, placeholder: "0.00", alignment: .trailing))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)

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
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .background(Constants.secondaryColor)
                    .cornerRadius(10)


                    Divider()

                    // Recieve
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                        Text("Recieve")
                            .foregroundColor(.white)
                        Spacer()
                        // Recieve input
                        TextField("", text: $viewModel.buyValue)
                            .modifier(PlaceholderStyle(showPlaceHolder: viewModel.buyValue.isEmpty, placeholder: "0.00", alignment: .trailing))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)

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
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .background(Constants.secondaryColor)
                    .cornerRadius(10)
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
                .padding(.horizontal, Constants.buttonHorizontalPadding)
            }
            .padding()
            .alert(viewModel.viewAlertContent?.title ?? "Done",
                   isPresented: $viewModel.presentingAlert,
                   presenting: $viewModel.viewAlertContent,
                   actions: { _ in
                Button("OK", action: {})
            }, message: { _ in
                Text(viewModel.viewAlertContent?.message ?? "")
            })
            .navigationTitle(Text("Currency converter"))
            .navigationBarTitleDisplayMode(.inline)
            .background(Constants.color.edgesIgnoringSafeArea(.all))
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = MainViewModel()
        MainContentView(viewModel: vm)
    }
}
