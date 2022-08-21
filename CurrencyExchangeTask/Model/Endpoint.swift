//
//  Endpoint.swift
//  MVVMCApp
//
//  Created by Daniil Veramei on 21.04.2022.
//

import Foundation

struct Endpoint {
    let host: String
    let path: String
    let headers: [String: String]
    let queryItems: [URLQueryItem]
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}
