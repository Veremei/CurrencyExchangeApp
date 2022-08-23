//
//  Currency.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 20.08.2022.
//

import Foundation

enum Currency: String, CaseIterable, Identifiable, Hashable, Codable {
    case EUR
    case USD
    case GBP

    var id: Self { self }
}

extension Currency {
    static let defaultList: [Currency] = [.EUR, .USD, .GBP]
}
