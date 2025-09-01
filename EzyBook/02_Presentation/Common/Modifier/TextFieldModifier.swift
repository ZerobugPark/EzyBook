//
//  TextFieldModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

private struct TextFieldModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding() // 텍스트 필드 내부 여백
            .background(Color.grayScale60.opacity(0.1)) // 회색 배경 추가
            .cornerRadius(15) // 모서리 둥글게 하기
            .padding(.top, 5) // 상단 여백 추가
            .padding(.horizontal, 2)
    }
}


extension View {
    
    func textFieldModify() -> some View {
        modifier(TextFieldModifier())
    }
}
