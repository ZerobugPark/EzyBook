//
//  OnLoginSuccessModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import SwiftUI

private struct OnLoginSuccessModifier: ViewModifier {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authModel: AuthModelObject
    let loginState: Bool
    
    
    func body(content: Content) -> some View {
        content
            .background( //.onChange, .onAppear은 Modifier에서 직접적으로 사용이 어려움, 뷰에서 티가 나지 않게 백그라운드에서 처리
                Group {
                    if #available(iOS 17.0, *) { // 컬러가 변하지 않더라도 onChage 상태에 따라 변환
                        Color.clear.onChange(of: loginState) { _, newValue in
                            if newValue {
                                appState.isLoggedIn = true
                                authModel.popToRoot()
                            }
                        }
                    } else {
                        Color.clear.onChange(of: loginState) { newValue in
                            if newValue {
                                appState.isLoggedIn = true
                                authModel.popToRoot()
                            }
                        }
                    }
                }
            )
    }
}


extension View {
    
    func onLoginSuccessModify(_ state: Bool) -> some View {
        modifier(OnLoginSuccessModifier(loginState: state))
    }
}
