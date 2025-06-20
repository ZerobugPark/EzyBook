//
//  View+Extension.swift
//  EzyBook
//
//  Created by youngkyun park on 5/17/25.
//

import SwiftUI

extension View {
    func commonAlert(isPresented: Binding<Bool>, title: String?, message: String?,  onDismiss: (() -> Void)? = nil) -> some View {
        self.alert(isPresented: isPresented) {
            Alert(
                title: Text(title ?? "오류"),
                message: Text(message ?? "알 수 없는 오류입니다. 관리자에게 문의해주세요."),
                dismissButton: .default(Text("확인"), action: {
                    onDismiss?()
                })
            )
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
