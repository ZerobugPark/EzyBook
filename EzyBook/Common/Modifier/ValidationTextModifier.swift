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
    
    func vaildTextdModify(_ state: EmailValidationState) -> some View {
        var emailState: Bool
        
        switch state {
        case .empty:
            emailState = false
        case .invalidFormat:
            emailState = true
        case .duplicated:
            emailState = true
        case .available:
            emailState = true
        }
        
        return modifier(ValidationTextModifier(isVaild: emailState))
    }
}
