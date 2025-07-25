//
//  ValidationTextModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import Foundation

import SwiftUI

private struct ValidationTextModifier: ViewModifier {
    
    let isVaild: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.top, 5)
            .appFont(PretendardFontStyle.caption1, textColor: isVaild ? .grayScale100 : .grayScale60)
    }
}


extension View {
    
    func vaildTextdModify(_ isVaild: Bool) -> some View {
        modifier(ValidationTextModifier(isVaild: isVaild))
    }

}
