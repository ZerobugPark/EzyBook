//
//  LoadingOverlayModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/30/25.
//

import SwiftUI

private struct LoadingOverlayModifier: ViewModifier {
    
    @EnvironmentObject var appState: AppState
    
    let loadingState: Bool
    
    
    func body(content: Content) -> some View {
        content
            .background( //.onChange, .onAppear은 Modifier에서 직접적으로 사용이 어려움, 뷰에서 티가 나지 않게 백그라운드에서 처리
                Group {
                    if #available(iOS 17.0, *) { // 컬러가 변하지 않더라도 onChage 상태에 따라 변환
                        Color.clear.onChange(of: loadingState) { _, newValue in
                            appState.isLoding = newValue
                        }
                    } else {
                        Color.clear.onChange(of: loadingState) { newValue in
                            appState.isLoding = newValue
                        }
                    }
                }
            )
    }
}


extension View {
    
    func loadingOverlayModify(_ state: Bool) -> some View {
        modifier(LoadingOverlayModifier(loadingState: state))
    }
}
