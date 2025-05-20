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
    
    @StateObject var container = AppDIContainer().makeDIContainer()
    
    init() {
        guard let KaKaoNativeKey = Bundle.main.object(forInfoDictionaryKey: "Kakao_NativeKey") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        KakaoSDK.initSDK(appKey: KaKaoNativeKey)
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(container)
                .onOpenURL(perform: { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
            
        }
    }
}
