//
//  ExchangeRateService.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 20.08.2022.
//

import Foundation

enum ExchangeRateServiceError: Error {
    case generic
}

final class ExchangeRateService {
    private let networkService: NetworkServiceProtocol
    private let walletService: WalletServiceProtocol

    private let apikey = "i1PMfVUbzMxWJlyZ8ONvqnjbdMZnbKYF"

    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         walletService: WalletServiceProtocol = WalletService.shared) {
        self.networkService = networkService
        self.walletService = walletService
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
                    completion(.success(rateResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
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

