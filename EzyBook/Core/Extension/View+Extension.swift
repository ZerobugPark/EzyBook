//
//  View+Extension.swift
//  EzyBook
//
//  Created by youngkyun park on 5/17/25.
//

import SwiftUI

extension View {
    func commonAlert(isPresented: Binding<Bool>, title: String?, message: String?) -> some View {
        self.alert(isPresented: isPresented) {
            Alert(
                title: Text(title ?? "오류"),
                message: Text(message ?? "알 수 없는 오류입니다. 관리자에게 문의해주세요."),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}
