//
//  TextFieldHelpers.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var alignment: Alignment

    public func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(Color.gray)
//                .padding(.horizontal, 5)
            }
            content
            .foregroundColor(Color.white)
//            .padding(.horizontal, 5)
        }
    }
}
