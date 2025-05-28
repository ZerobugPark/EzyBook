//
//  FontModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import SwiftUI




struct AppFontModifier: ViewModifier {
    
    let style: FontStyle
    let textColor: Color?

    func body(content: Content) -> some View {
        if let textColor = textColor {
            content
                .font(.custom(style.fontName, size: style.size))
                .foregroundStyle(textColor)
        } else {
            content
                .font(.custom(style.fontName, size: style.size))
        }
     }
}

extension View {
    func appFont(_ style: FontStyle, textColor: Color? = nil) -> some View {
        self.modifier(AppFontModifier(style: style, textColor: textColor))
    }
}
