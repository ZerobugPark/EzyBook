//
//  TokenManager.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import SwiftUI
import Combine


/// 토근 관련 매니저 (저장, 갱신 등)
final class TokenService {
    
    private let storage: TokenStorage
    private let scheduler :TokenRefreshScheduler
    
    init(storage: TokenStorage, scheduler: TokenRefreshScheduler) {
        self.storage = storage
        self.scheduler = scheduler
    }
    
    //토큰에 개발저장이 필요하다면 (확장성 고려)
    func saveToken(key: String, value: String) -> Bool {
        let result = storage.saveToken(key: key, value: value)
        return result
            
    }
    
    func saveTokens(accessToken: String, refreshToken: String) -> Bool {
        let accessSaved = storage.saveToken(key: KeyChainManger.accessToken, value: accessToken)
        let refreshSaved = storage.saveToken(key: KeyChainManger.refreshToken, value: refreshToken)
        
        return accessSaved && refreshSaved
    }
    
    
    func loadToken(key: String) -> String? {
        storage.loadToken(key: key)
    }
    
    func deleteToken(key: String) -> Bool {
        let result =  storage.deleteToken(key: key)
        return result
    }
    
}

extension TokenService {
//   여기서 갱신하는 플로우 필요해보임
//    private func refreshTokenIfNeeded() async throws {
//     
//        guard let accessToken = storage.loadToken(key: KeyChainManger.accessToken),
//              let refreshToken = storage.loadToken(key: KeyChainManger.refreshToken) else {
//            return
//        }
//    
//        let router = AuthRequest.refresh(accessToken: accessToken, refreshToken: refreshToken)
//        
//        let response = try await networkManager.fetchData(dto: AuthResponseDTO.self, router)
//        
//        let _ = tokenManager.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
//    }
}
