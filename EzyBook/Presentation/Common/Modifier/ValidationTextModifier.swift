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
            .foregroundStyle(isVaild ? .grayScale100 : .grayScale60)
            .font(.system(size: 12))
    }
}


extension View {
    
    func vaildTextdModify(_ isVaild: Bool) -> some View {
        modifier(ValidationTextModifier(isVaild: isVaild))
    }

}
