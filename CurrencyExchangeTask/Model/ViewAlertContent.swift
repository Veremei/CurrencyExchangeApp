//
//  ViewAlertContent.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import Foundation

struct ViewAlertContent: Identifiable {
    var id: String { title }
    let title: String
    let message: String
}
