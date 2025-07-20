//
//  EzyBookApp.swift
//  EzyBook
//
//  Created by youngkyun park on 5/10/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import KakaoSDKCommon
import KakaoSDKAuth

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: { _, _ in }
//        )
//        
//        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            print("🔔 권한 granted: \(granted)")
            if let error = error {
                print("❌ 권한 요청 에러: \(error.localizedDescription)")
            }

            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("⚠️ 사용자 푸시 권한 거부")
            }
        }
        
        // 메시지 대리자 설정.
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
        
        return true
    }
    

    
    
}


@main
struct EzyBookApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var container = AppDIContainer().makeDIContainer()
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
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
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        Task {
                            await container.imageLoader.cleanUpDiskCache()
                            
                            do {
                                try await container.initializeAppSession()
                                appState.isLoggedIn = true
                            } catch {
                                appState.isLoggedIn = false
                            }
                            
                        }
                    }
                }
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


extension AppDelegate: MessagingDelegate {
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))") // 디바이스 토큰과 다르다.
        print("✅ FCM token received: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ APNs token received: \(tokenString)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
}

extension AppDelegate {
    // 앱 화면을 보고있는 중(포그라운드)에 푸시 올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        print("😎", #function)
        
        // 푸시 알림 데이터가 userInfo에 담겨있다.
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        
        if #available(iOS 14.0, *) {
            return [.sound, .banner, .list]
        } else {
            return []
        }
    }
    

}

