//
//  TitleSectionButtonModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI

private struct TitleButtonModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .appFont(PretendardFontStyle.body1, textColor: .deepSeafoam)
    }
}


extension View {
    
    func titleButtonModify() -> some View {
        modifier(TitleButtonModifier())
    }
}
