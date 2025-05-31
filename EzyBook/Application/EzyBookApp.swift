//
//  EzyBookApp.swift
//  EzyBook
//
//  Created by youngkyun park on 5/10/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct EzyBookApp: App {
    
    @StateObject private var container = AppDIContainer().makeDIContainer()
    @StateObject private var appState = AppState()
    

    
    init() {
        guard let KaKaoNativeKey = Bundle.main.object(forInfoDictionaryKey: "Kakao_NativeKey") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        KakaoSDK.initSDK(appKey: KaKaoNativeKey)
        setupNavigationBarApperance()
        
        
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(container)
                .environmentObject(appState)
                .onOpenURL(perform: { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}


extension EzyBookApp {
    
    
    private func setupNavigationBarApperance() {
        let appearance = UINavigationBarAppearance()
        //appearance.configureWithTransparentBackground() // 배경 투명하게
        appearance.shadowColor = .clear // 하단 줄 제거

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}


