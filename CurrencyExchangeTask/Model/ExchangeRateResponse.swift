//
//  ExchangeRateResponse.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 21.08.2022.
//

import Foundation

struct ExchangeRateResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case timestamp, base, rates
    }

    let timestamp: Double?
    let base: String
    let rates: [String: Double]
}

struct ExchangeRateResponseError: Decodable {
    let error: ExchangeRateResponseErrorDetails
}

struct ExchangeRateResponseErrorDetails: Decodable {
    let code: String
    let message: String
}



struct ConvertRateResponse: Decodable {
    let info: ConvertRateResponseInfo
    let result: Double
}

struct ConvertRateResponseInfo: Decodable {
    let rate: Double
}
