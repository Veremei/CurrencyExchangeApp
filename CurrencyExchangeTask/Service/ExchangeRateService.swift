//
//  ExchangeRateService.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 20.08.2022.
//

import Foundation

struct ExchangeRateOperation {
    let operationsAmount: Int
    let date: Date
}

enum ExchangeRateServiceError: Error {
    case generic
}

protocol ExchangeRateServiceProtocol {
    var reguralFee: Double { get }

    func loadRates(for base: Currency, with symbols: [Currency], completion: @escaping (Result<ExchangeRateResponse, Error>) -> Void)
    func convert(amount: String, from: Currency, to: Currency, completion: @escaping (Result<ConvertRateResponse, Error>) -> Void)
    func getFee(amount: Double, for currency: Currency, feeRate: Double) -> Double
}

final class ExchangeRateService: ExchangeRateServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let walletService: WalletServiceProtocol

    private let apikey = "i1PMfVUbzMxWJlyZ8ONvqnjbdMZnbKYF"


    private(set) var reguralFee: Double = 0
    private var operationsAmount = 0 {
        didSet {
            let exchangeRateOperation = ExchangeRateOperation(operationsAmount: operationsAmount, date: Date())

            UserDefaults.standard.set(exchangeRateOperation, forKey: "exchangeRateOperations")

            switch operationsAmount {

                /// The first five currency exchanges are free of charge
            case ..<5:
                reguralFee = 0

                /// afterwards they're charged 0.7% of the currency being traded
            case 5..<15:
                reguralFee = 0.007
            case 15...:
                reguralFee = 0.012
            default:
                reguralFee = 0
            }
        }
    }

    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         walletService: WalletServiceProtocol = WalletService.shared) {
        self.networkService = networkService
        self.walletService = walletService

        #warning("Implement exchangeRateOperations loading")
        let cachedOperations = UserDefaults.standard.object(forKey: "exchangeRateOperations") as? ExchangeRateOperation
        operationsAmount = cachedOperations?.operationsAmount ?? 0
    }

    // TODO: Add timestamp to sync currency, avoid multiple calls(caching)
    func loadRates(for base: Currency, with symbols: [Currency], completion: @escaping (Result<ExchangeRateResponse, Error>) -> Void) {
        let joinedSymbols = symbols.map { $0.rawValue }.joined(separator: ",")
        let endpoint = Endpoint(host: "api.apilayer.com",
                                path: "/exchangerates_data/latest",
                                headers: ["apikey": apikey],
                                queryItems: [
                                    URLQueryItem(name: "base", value: base.rawValue),
                                    URLQueryItem(name: "symbols", value: joinedSymbols)])

        networkService.request(endpoint: endpoint) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                
                if let decodedError = self.decodeError(from: data) {
                    //                    let err = NSError(domain: "", code: rateResponse.code, userInfo: [NSLocalizedDescriptionKey: rateResponse.message])
                    // TODO: https://peterfriese.dev/posts/swiftui-combine-networking-errorhandling/
                    completion(.failure(decodedError))
                    return
                }

                do {
                    let rateResponse = try decoder.decode(ExchangeRateResponse.self, from: data)
                    completion(.success(rateResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func convert(amount: String, from: Currency, to: Currency, completion: @escaping (Result<ConvertRateResponse, Error>) -> Void) {
        let endpoint = Endpoint(host: "api.apilayer.com",
                                path: "/exchangerates_data/convert",
                                headers: ["apikey": apikey],
                                queryItems: [
                                    URLQueryItem(name: "to", value: to.rawValue),
                                    URLQueryItem(name: "from", value: from.rawValue),
                                    URLQueryItem(name: "amount", value: amount)
                                ])

        networkService.request(endpoint: endpoint) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                let decoder = JSONDecoder()

                if let decodedError = self.decodeError(from: data) {
                    //                    let err = NSError(domain: "", code: rateResponse.code, userInfo: [NSLocalizedDescriptionKey: rateResponse.message])
                    // TODO: https://peterfriese.dev/posts/swiftui-combine-networking-errorhandling/
                    completion(.failure(decodedError))
                    return
                }

                do {
                    let rateResponse = try decoder.decode(ConvertRateResponse.self, from: data)

                    self.operationsAmount += 1
                    completion(.success(rateResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getFee(amount: Double, for currency: Currency, feeRate: Double = 1) -> Double {
        return 0
    }

    // TODO: handle error
    private func decodeError(from data: Data) -> Error? {
        if let _ = try? JSONDecoder().decode(ExchangeRateResponseError.self, from: data).error {
            //                    let err = NSError(domain: "", code: rateResponse.code, userInfo: [NSLocalizedDescriptionKey: rateResponse.message])
            // TODO: https://peterfriese.dev/posts/swiftui-combine-networking-errorhandling/
        }
        return ExchangeRateServiceError.generic
    }
}

final class ExchangeRateServiceMock: ExchangeRateServiceProtocol {
    private(set) var reguralFee: Double = 0 {
        didSet {
            print("regular fee changed to", reguralFee)
        }
    }

    private var operationsAmount = 0 {
        didSet {
//            let exchangeRateOperation = ExchangeRateOperation(operationsAmount: operationsAmount, date: Date())
            UserDefaults.standard.set(["operationsAmount": operationsAmount, "date": Date()], forKey: "exchangeRateOperations")
            updateFeeValue()
        }
    }

    init() {
        print(#function)
        if let cachedOperations = UserDefaults.standard.dictionary(forKey: "exchangeRateOperations"),
           let operations = cachedOperations["operationsAmount"] as? Int,
           let lastDate = cachedOperations["date"] as? Date {

            // - conversions per day
            if Calendar.current.isDateInToday(lastDate) {
                operationsAmount = operations
                updateFeeValue()
            } else {
                UserDefaults.standard.set(["operationsAmount": 0, "date": Date()], forKey: "exchangeRateOperations")
            }
        }
    }

    func loadRates(for base: Currency, with symbols: [Currency], completion: @escaping (Result<ExchangeRateResponse, Error>) -> Void) {
        let rates = Dictionary(uniqueKeysWithValues: symbols.map{ ($0.rawValue, Double.random(in: 0...1)) })
        completion(.success(ExchangeRateResponse(timestamp: Date().timeIntervalSince1970, base: base.rawValue, rates: rates)))
        return
    }

    func convert(amount: String, from: Currency, to: Currency, completion: @escaping (Result<ConvertRateResponse, Error>) -> Void) {
        let rate = Double.random(in: 0.5...2)
        completion(.success(ConvertRateResponse(info: .init(rate: rate), result: (Double(amount) ?? 1) * rate)))
        operationsAmount += 1
        return
    }

    func getFee(amount: Double, for currency: Currency, feeRate: Double = 1) -> Double {
        return (amount * reguralFee) + getAdditionalFee(amount: amount, rate: feeRate)
    }

    func getAdditionalFee(amount: Double, rate: Double) -> Double {
        switch operationsAmount {
        case 15...:
            return 0.3 * rate
        default:
            return 0
        }
    }

    private func updateFeeValue() {
        switch operationsAmount {

            /// The first five currency exchanges are free of charge
        case ..<5:
            reguralFee = 0

            /// afterwards they're charged 0.7% of the currency being traded
        case 5..<15:
            reguralFee = 0.007
        case 15...:
            reguralFee = 0.012
        default:
            reguralFee = 0
        }
    }
}
