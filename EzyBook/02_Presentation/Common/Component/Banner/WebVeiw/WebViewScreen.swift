//
//  WebViewScreen.swift
//  EzyBook
//
//  Created by youngkyun park on 7/21/25.
//

import SwiftUI

struct WebViewScreen: View {
    
    
    let tokenManager: TokenStorage
    @ObservedObject var coordinator: HomeCoordinator
    let onComplete: ((String) -> Void)?


    private let url = URL(string: APIConstants.baseURL + "/event-application")!
    
    var body: some View {
        ZStack {
            WebView(
                tokenManger: tokenManager,
                url: url) { msg in
                    onComplete?(msg)
                }
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    BackButtonView {
                        coordinator.pop()
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
