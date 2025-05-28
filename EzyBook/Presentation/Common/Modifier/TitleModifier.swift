//
//  TitleModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI


private struct TitleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
    }
}


extension View {
    
    func titleModify() -> some View {
        modifier(TitleModifier())
    }
}
