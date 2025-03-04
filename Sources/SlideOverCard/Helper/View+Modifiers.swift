//
//  View+Modifiers.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 24/04/21.
//

import SwiftUI

extension View {
    /// Present a `SlideOverCard` with a boolean binding
    public func slideOverCard<Content: View, Style: ShapeStyle>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        options: SOCOptions = [],
        style: SOCStyle<Style> = SOCStyle(),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        return self
            .modifier(SOCModifier(isPresented: isPresented,
                                  options: options,
                                  style: style,
                                  content: content))
    }
}
