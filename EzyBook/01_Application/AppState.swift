//
//  AppState.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoding = false

    /// 푸시 관련 화면 전환
    @Published var pendingRoomID: String? = nil
}
