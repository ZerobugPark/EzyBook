//
//  TokenRefreshable.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation

/// Sendable 동시성에서 안전한 타입이라고 명시
protocol TokenRefreshable: Sendable {
    var accessToken: String? { get }
    func refreshToken() async throws
}
