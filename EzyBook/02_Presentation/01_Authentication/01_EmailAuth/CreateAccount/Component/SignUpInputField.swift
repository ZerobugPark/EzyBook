//
//  SignUpInputField.swift
//  EzyBook
//
//  Created by youngkyun park on 7/23/25.
//

import SwiftUI

struct ValidationMessage: Identifiable {
    let id = UUID()
    let message: String
    let isValid: Bool
}

struct SignUpInputField: View {
    
    let title: String
    let placeholder: String
    @Binding var text: String
    var isRequired: Bool
    var focusField: FocusState<SignUpFocusField?>.Binding
    var field: SignUpFocusField
    var onSubmit: (() -> Void)? = nil
    var validations: [ValidationMessage] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            /// 타이틀 섹션
            FieldTitle(title: title, isRequired: isRequired)
            
            TextField(placeholder, text: $text)
                .keyboardType(field.keyboardType)
                .textFieldModify()
                .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                .focused(focusField, equals: field)
                .onSubmit {
                    onSubmit?()
                }
            
            ForEach(validations, id: \.id) { validations in
                Text(validations.message)
                    .appFont(PretendardFontStyle.caption1)
                    .vaildTextdModify(validations.isValid)
            }
        
            
            
        }
    }
    
}



struct FieldTitle: View {
    
    let title: String
    let isRequired: Bool
    
    var body: some View {
        
        
        HStack(spacing: 2) {
            Text(title)
                .appFont(PretendardFontStyle.body1)
            if isRequired {
                Text("*")
                    .foregroundColor(.red)
                    .appFont(PretendardFontStyle.body2)
            }
        }
        
        
    }
}
