//
//  DefaultTokenRefreshScheduler.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import SwiftUI

/// TokenRefreshScheduler
/// DefaultAuthNetworkRepository에서 타이머를 관리할 경우 너무 책임이 커지기 때문에 분리
final class DefaultTokenRefreshScheduler: TokenRefreshScheduler {
    
    
    private var timer: DispatchSourceTimer?
    private let refreshInterval: TimeInterval = 115 * 60 // 115분마다 갱신 (120분마다 갱신)
    
    func start(refreshAction: @escaping () async -> Void) {
        stop()
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now() + refreshInterval, repeating: refreshInterval)
        
        timer.setEventHandler {
            Task {
                await refreshAction()
            }
        }
        
        self.timer = timer
        timer.resume()
        
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
    }
    
}
