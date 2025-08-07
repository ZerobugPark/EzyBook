//
//  NotificationPermissionObserver.swift
//  EzyBook
//
//  Created by youngkyun park on 8/8/25.
//

import SwiftUI

class NotificationPermissionObserver: ObservableObject {
    @Published private(set) var status: UNAuthorizationStatus = .notDetermined
    private var previousStatus: UNAuthorizationStatus?

    init() {
        // 1) 처음 상태 불러오기
        refreshStatus()
        
        // 2) 포그라운드 복귀 시마다 상태 갱신
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshStatus),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func refreshStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let newStatus = settings.authorizationStatus
                if let old = self.previousStatus, old != newStatus {
                    // 상태가 변경됨
                    print("📣 Notification permission changed: \(old) → \(newStatus)")
                    // 여기서 필요한 대응(알림 띄우기, 서버에 보고 등)을 할 수 있습니다.
                }
                self.previousStatus = newStatus
                self.status = newStatus
            }
        }
    }
}

// MARK: - Notification.Name Extensions for Chat Room Notifications
extension Notification.Name {
    /// 사용자 채팅방 입장 알림
    static let didEnterChatRoom = Notification.Name("didEnterChatRoom")
    /// 사용자 채팅방 퇴장 알림
    static let didLeaveChatRoom = Notification.Name("didLeaveChatRoom")
}

