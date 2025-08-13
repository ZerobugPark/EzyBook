//
//  EzyBookApp.swift
//  EzyBook
//
//  Created by youngkyun park on 5/10/25.
//

import SwiftUI
import Combine
import FirebaseCore
import FirebaseMessaging
import KakaoSDKCommon
import KakaoSDKAuth

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    /// 현재 활성화된 채팅 방 ID
    private var activeChatRoomID: String?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        
        UNUserNotificationCenter.current().delegate = self
        
        // 채팅 화면 입장/퇴장 알림 수신
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterChatRoom(_:)),
            name: Notification.Name("didEnterChatRoom"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didLeaveChatRoom(_:)),
            name: Notification.Name("didLeaveChatRoom"),
            object: nil
        )
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        application.registerForRemoteNotifications()
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
    
    
    
    
    @objc private func didEnterChatRoom(_ notification: Notification) {
        activeChatRoomID = notification.object as? String
    }
    
    @objc private func didLeaveChatRoom(_ notification: Notification) {
        activeChatRoomID = nil
    }
}


@main
struct EzyBookApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var container = AppDIContainer()
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var notifier = NotificationPermissionObserver()
    
    @State private var isBootstrapping = true        // 초기화 진행 중
    @State private var didInitOnce = false           // 첫 초기화 완료 여부 (재진입시 중복 방지)
    
    /// AppStorage로 설치 마커 관리
    /// 지웠다 삭제시 키체인 삭제
    @AppStorage("com.myapp.firstInstallDone") private var didInstallBefore: Bool = false
    
    
    init() {
        guard let KaKaoNativeKey = Bundle.main.object(forInfoDictionaryKey: "Kakao_NativeKey") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        KakaoSDK.initSDK(appKey: KaKaoNativeKey)
        setupNavigationBarApperance()
        
        if !didInstallBefore {
            if KeychainHelper.hasAnyItem() {
                // 재설치된 상태 → Keychain 초기화
                KeychainHelper.deleteAllItems()
                print("🔒 재설치 감지: Keychain 초기화 완료")
            }
            // 이후 실행부터는 검사 로직 건너뛰도록 마커 설정
            didInstallBefore = true
        }
        
        
    }
    
    
    var body: some Scene {
        WindowGroup {
            
            Group {
                if !didInitOnce {
                    EzyBookSplashView()

                } else {
                    AppEntryView()
                }
            }
            .environmentObject(container)
            .environmentObject(appState)
            .task { // 최초 진입 시 1회 초기화
                guard didInitOnce == false else { return }
                await bootstrap()
                
                didInitOnce = true
            }
            .task(id: scenePhase) {            // 2) 포그라운드 복귀: 가벼운 재개 작업
                guard scenePhase == .active else { return }
                
                // 부트스트랩 직후는 호출 X
                guard didInitOnce else { return }
                // await resumeIfNeeded()
            }
            .onOpenURL(perform: { url in
                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
            })
            .onSubmit {
                /// 푸시 상태 변경시 디바이스 토근 업데이트 필요
                print("Current permission:", notifier.status)
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveDeepLink)) { note in
                guard
                    let info = note.userInfo as? [String: Any],
                    let type = info["type"] as? String, type == "chat",
                    let roomID = info["roomID"] as? String
                else { return }
                
                // Buffer for consumption when UI is ready (covers suspended/cold start)
                appState.pendingRoomID = roomID
            }
        }
        
    }
    
    @MainActor
    private func bootstrap() async {
        // Run in parallel: disk cache cleanup, session validation, and a minimum splash delay
        async let cleanup: Void = container.cacheManager.cleanUpDiskCache()
        async let session: Void = validateAppSession()
        async let minDelay: Void = { try? await Task.sleep(nanoseconds: 500_000_000) }()
        
        _ = await(cleanup, session, minDelay)
    }
    
    // 선택: 복귀 시 가벼운 처리만
    @MainActor
    private func resumeIfNeeded() async {
        await validateAppSession()
    }
    
    @MainActor
    private func validateAppSession() async {
        do {
            try await container.initializeAppSession()
            appState.isLoggedIn = true
        } catch {
            appState.isLoggedIn = false
        }
    }
}



// MARK: Navigation Setting
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
    
    /// FCM 토큰 업데이트
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        guard let fcmToken else { return }
        UserDefaultManager.fcmToken = fcmToken
        
        // 서버로 보냘 때, fcm 토큰을 보내야함
        print("Firebase registration token: \(String(describing: fcmToken))") // 디바이스 토큰과 다르다.
        print("✅ FCM token received: \(String(describing: fcmToken))")
        
        
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
    }
    
    /// 스위즐링 No시 APNs 등록,  토큰값 가져옴
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ APNs token received: \(tokenString)")
        Messaging.messaging().apnsToken = deviceToken
        
    }
    
    // error 발생
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
}

extension AppDelegate {
    // 앱 화면을 보고있는 중(포그라운드)에 푸시 올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        print("userInfo", userInfo)
        
        // 동일 채팅방에 있으면 푸시 억제
        if let roomID = userInfo["room_id"] as? String,
           roomID == activeChatRoomID {
            return []
        }
        
        //print(userInfo)
        /// 앱을 사용중이면, 탭시 이전화면으로 이동, 사용중이 않다면 홈으로 이동
        
        /// 기본 노출 옵션
        /// sound 알람
        /// banner: 배너
        /// list: 알림센터
        if #available(iOS 14.0, *) {
            return [.banner]
        } else {
            return []
        }
    }
    
    
    /// 푸시 클릭시
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
        
        let userInfo = response.notification.request.content.userInfo
        guard let roomID = userInfo["room_id"] as? String else { return }
        
        
        /// 앱 상태를 확인해야 하니 살짝 지연
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NotificationCenter.default.post(
                name: .didReceiveDeepLink,
                object: nil,
                userInfo: ["type":"chat", "roomID": roomID]
            )
            print("📤 didReceiveDeepLink posted → roomID:\(roomID)")
        }
        
    }
}
