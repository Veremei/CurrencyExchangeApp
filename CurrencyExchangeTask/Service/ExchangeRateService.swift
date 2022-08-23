//
//  ExchangeRateService.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 20.08.2022.
//

import Foundation
import Combine

struct ExchangeRateOperation {
    let operationsAmount: Int
    let date: Date
}

enum ExchangeRateServiceError: Error, LocalizedError {
    case generic
    case error(message: String)

    public var errorDescription: String? {
        switch self {
        case .generic:
            return "An error occured"
        case .error(let message):
            return message
        }
    }
}

protocol ExchangeRateServiceProtocol {
    var reguralFee: Double { get }

    func loadRates(for base: Currency, with symbols: [Currency]) -> AnyPublisher<ExchangeRateResponse, Error>
    func convert(amount: String, from: Currency, to: Currency) -> AnyPublisher<ConvertRateResponse, Error>
    func getFee(amount: Double, for currency: Currency, feeRate: Double) -> Double
}

final class ExchangeRateService: ExchangeRateServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private unowned let walletService: WalletServiceProtocol

    // TODO: hide api in secrets
    private let apikey = "5ervFjYovs8rEWtc8e4A2Wx3OHj84Fqd"

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private(set) var reguralFee: Double = 0
    private var cancellables: Set<AnyCancellable> = []
    private var operationsAmount = 0 {
        didSet {
            UserDefaults.standard.set(["operationsAmount": operationsAmount, "date": Date()], forKey: "exchangeRateOperations")
            updateFeeValue()
        }
    }
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         walletService: WalletServiceProtocol) {
        self.networkService = networkService
        self.walletService = walletService

        if let cachedOperations = UserDefaults.standard.dictionary(forKey: "exchangeRateOperations"),
           let operations = cachedOperations["operationsAmount"] as? Int,
           let lastDate = cachedOperations["date"] as? Date {

            // - exchanges per day
            if Calendar.current.isDateInToday(lastDate) {
                operationsAmount = operations
                updateFeeValue()
            } else {
                UserDefaults.standard.set(["operationsAmount": 0, "date": Date()], forKey: "exchangeRateOperations")
            }
        }
    }

    // TODO: Add timestamp to sync currency, avoid multiple calls(caching)
    func loadRates(for base: Currency, with symbols: [Currency]) -> AnyPublisher<ExchangeRateResponse, Error> {
        let joinedSymbols = symbols.map { $0.rawValue }.joined(separator: ",")
        let endpoint = Endpoint(host: "api.apilayer.com",
                                path: "/exchangerates_data/latest",
                                headers: ["apikey": apikey],
                                queryItems: [
                                    URLQueryItem(name: "base", value: base.rawValue),
                                    URLQueryItem(name: "symbols", value: joinedSymbols)])

        return networkService.request(endpoint: endpoint)
            .receive(on: DispatchQueue.main)
            .mapError { $0 as Error }
            .flatMap { data -> AnyPublisher<ExchangeRateResponse, Error> in
                let decoder = JSONDecoder()

                if let decodedError = self.decodeError(from: data) {
                    return Fail(error: decodedError)
                        .eraseToAnyPublisher()
                }

                return Just(data)
                    .decode(type: ExchangeRateResponse.self, decoder: decoder)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func convert(amount: String, from: Currency, to: Currency) -> AnyPublisher<ConvertRateResponse, Error> {
        let endpoint = Endpoint(host: "api.apilayer.com",
                                path: "/exchangerates_data/convert",
                                headers: ["apikey": apikey],
                                queryItems: [
                                    URLQueryItem(name: "to", value: to.rawValue),
                                    URLQueryItem(name: "from", value: from.rawValue),
                                    URLQueryItem(name: "amount", value: amount)
                                ])
        return networkService.request(endpoint: endpoint)
            .receive(on: DispatchQueue.main)
            .mapError { $0 as Error }
            .flatMap { data -> AnyPublisher<ConvertRateResponse, Error> in
                let decoder = JSONDecoder()

                if let decodedError = self.decodeError(from: data) {
                    return Fail(error: decodedError)
                        .eraseToAnyPublisher()
                }

                do {
                    let rateResponse = try decoder.decode(ConvertRateResponse.self, from: data)
                    self.operationsAmount += 1
                    return Just(rateResponse)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                    
                } catch {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
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

    private func decodeError(from data: Data) -> Error? {
        if let error = try? JSONDecoder().decode(ExchangeRateResponseError.self, from: data).error {
            return ExchangeRateServiceError.error(message: error.message)
        } else if let error = try? JSONDecoder().decode(ExchangeRateResponseErrorDetails.self, from: data).message {
            return ExchangeRateServiceError.error(message: error)
        }
        return nil
    }
}





//final class ExchangeRateServiceFake: ExchangeRateServiceProtocol {
//    private(set) var reguralFee: Double = 0
//
//    private var operationsAmount = 0 {
//        didSet {
//            UserDefaults.standard.set(["operationsAmount": operationsAmount, "date": Date()], forKey: "exchangeRateOperations")
//            updateFeeValue()
//        }
//    }
//
//    init() {
//        print(#function)
//        if let cachedOperations = UserDefaults.standard.dictionary(forKey: "exchangeRateOperations"),
//           let operations = cachedOperations["operationsAmount"] as? Int,
//           let lastDate = cachedOperations["date"] as? Date {
//
//            // - conversions per day
//            if Calendar.current.isDateInToday(lastDate) {
//                operationsAmount = operations
//                updateFeeValue()
//            } else {
//                UserDefaults.standard.set(["operationsAmount": 0, "date": Date()], forKey: "exchangeRateOperations")
//            }
//        }
//    }
//
//    func loadRates(for base: Currency, with symbols: [Currency], completion: @escaping (Result<ExchangeRateResponse, Error>) -> Void) {
//        let rates = Dictionary(uniqueKeysWithValues: symbols.map{ ($0.rawValue, Double.random(in: 0...1)) })
//        completion(.success(ExchangeRateResponse(timestamp: Date().timeIntervalSince1970, base: base.rawValue, rates: rates)))
//        return
//    }
//
//    func convert(amount: String, from: Currency, to: Currency, completion: @escaping (Result<ConvertRateResponse, Error>) -> Void) {
//        let rate = Double.random(in: 0.5...2)
//        completion(.success(ConvertRateResponse(info: .init(rate: rate), result: (Double(amount) ?? 1) * rate)))
//        operationsAmount += 1
//        return
//    }
//
//    func getFee(amount: Double, for currency: Currency, feeRate: Double = 1) -> Double {
//        return (amount * reguralFee) + getAdditionalFee(amount: amount, rate: feeRate)
//    }
//
//    func getAdditionalFee(amount: Double, rate: Double) -> Double {
//        switch operationsAmount {
//        case 15...:
//            return 0.3 * rate
//        default:
//            return 0
//        }
//    }
//
//    private func updateFeeValue() {
//        switch operationsAmount {
//
//            /// The first five currency exchanges are free of charge
//        case ..<5:
//            reguralFee = 0
//
//            /// afterwards they're charged 0.7% of the currency being traded
//        case 5..<15:
//            reguralFee = 0.007
//        case 15...:
//            reguralFee = 0.012
//        default:
//            reguralFee = 0
//        }
//    }
//}
