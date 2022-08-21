//
//  NetworkService.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 31.07.2022.
//

import Foundation

enum NetworkServiceError: Error {
    case missingResponseData
    case parsingFailed
    case commonError
    case invalidResponse
}

protocol NetworkServiceProtocol {
    func request(endpoint: Endpoint, completion: @escaping (Result<Data, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private init() { }
    
    func request(endpoint: Endpoint, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = endpoint.url else { return }
        var urlRequest = URLRequest(url: url)

        endpoint.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let urlResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkServiceError.invalidResponse))
                return
            }
            print("response status code:", urlResponse.statusCode)
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkServiceError.missingResponseData))
                return
            }
            print(String(data: data, encoding: .utf8))
            completion(.success(data))
        }.resume()
    }
}


