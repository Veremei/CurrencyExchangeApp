//
//  NetworkService.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import Foundation
import Combine

enum NetworkServiceError: Error {
    case missingResponseData
    case parsingFailed
    case commonError
    case invalidResponse
}

protocol NetworkServiceProtocol {
    func request(endpoint: Endpoint) -> AnyPublisher<Data, Error>
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    private init() { }

    private let urlSession = URLSession.shared
    
    func request(endpoint: Endpoint) -> AnyPublisher<Data, Error> {
        guard let url = endpoint.url else {
            return Fail<Data, Error>(error: NetworkServiceError.commonError)
                .eraseToAnyPublisher()
        }

        var urlRequest = URLRequest(url: url)

        endpoint.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        return urlSession.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .mapError{ $0 as Error }
            .eraseToAnyPublisher()
    }
}


