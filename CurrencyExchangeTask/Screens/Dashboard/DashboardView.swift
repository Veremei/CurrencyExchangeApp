//
//  DashboardView.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

struct DashboardView: View {
    private struct Constants {
        // TODO: move to asset colors / app color scheme
        static let color = Color(red: 0.102, green: 0.057, blue: 0.196)
        static let secondaryColor = Color(red: 0.162, green: 0.134, blue: 0.251)

        static let buttonHorizontalPadding: CGFloat = 24
    }

    @ObservedObject private var viewModel: DashboardDefaultViewModel

    init(viewModel: DashboardDefaultViewModel) {
        self.viewModel = viewModel
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                bankAccounts
                currencyExchange
                Spacer()
                bottomButton
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

    @ViewBuilder
    private var bankAccounts: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My balances")
                .font(.body)
                .textCase(.uppercase)
                .foregroundColor(.white)

            viewModel.buildAccount()
                .onTapGesture(perform: {
                    viewModel.presentingTransactions = true
                })
                .frame(height: 100)
        }
    }

    @ViewBuilder
    private var currencyExchange: some View {
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

            CurrencyExchangeView()
                .environmentObject(viewModel)
        }
    }

    @ViewBuilder
    private var bottomButton: some View {
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
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(viewModel: DashboardDefaultViewModel(callback: { _ in
            return AnyView.defaultError
        }))
    }
}
