//
//  String+Extension.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation

extension String {
    var currencyCodeSymbol: String? {
        let locale = NSLocale(localeIdentifier: self)
        if locale.displayName(forKey: .currencySymbol, value: self) == self {
            let newlocale = NSLocale(localeIdentifier: self.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: self)
        }
        return locale.displayName(forKey: .currencySymbol, value: self)
    }

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
