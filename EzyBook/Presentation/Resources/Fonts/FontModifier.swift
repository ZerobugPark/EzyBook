//
//  FontModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import SwiftUI




struct AppFontModifier: ViewModifier {
    
    let style: FontStyle

    func body(content: Content) -> some View {
         content.font(.custom(style.fontName, size: style.size))
     }
}

extension View {
    func appFont(_ style: FontStyle) -> some View {
        self.modifier(AppFontModifier(style: style))
    }
}
