//
//  View+Extension.swift
//  CurrencyExchangeTask
//
//  Created by Daniil Veramei on 23.08.2022.
//

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension View {
    @inlinable func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        return frame(width: size.width, height: size.height, alignment: alignment)
    }

    func toAnyView() -> AnyView {
        AnyView(self)
    }

    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }

}

extension View {
    func push<V: View>(_ view: V, toggle: Binding<Bool>) -> some View {
        NavigationLink(destination: view, isActive: toggle) {
            EmptyView()
        }
    }
}

extension AnyView {
    static let defaultError = AnyView(Text("View does not exist"))
}
