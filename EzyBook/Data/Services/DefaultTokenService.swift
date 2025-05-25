//
//  TokenManager.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import SwiftUI
import Combine


/// 토근 관련 매니저 (저장, 갱신 등)
/// 이것도 구조체가 낫지않나?... 고민이네
struct DefaultTokenService: TokenWritable, TokenRefreshable {
    
    private let storage: TokenStorage
    private let networkService: NetworkService
    
    var accessToken: String? {
        loadToken(key: KeychainKeys.accessToken)
    }
    
    init(storage: TokenStorage, networkService: NetworkService) {
        self.storage = storage
        self.networkService = networkService
    }
    
    //토큰에 개발저장이 필요하다면 (확장성 고려)
    func saveToken(key: String, value: String) -> Bool {
        let result = storage.saveToken(key: key, value: value)
        return result
            
    }
    
    func saveTokens(accessToken: String, refreshToken: String) -> Bool {
        let accessSaved = storage.saveToken(key: KeychainKeys.accessToken, value: accessToken)
        let refreshSaved = storage.saveToken(key: KeychainKeys.refreshToken, value: refreshToken)
        
        return accessSaved && refreshSaved
    }
    
    
    func loadToken(key: String) -> String? {
        storage.loadToken(key: key)
    }
    
    /// 회원탈퇴할 때, 추가적으로 프로토콜 분리
    func deleteToken(key: String) -> Bool {
        let result =  storage.deleteToken(key: key)
        return result
    }
    
}

extension DefaultTokenService {
    
    func refreshToken() async throws {
        
        guard let accessToken = loadToken(key: KeychainKeys.accessToken), let refreshToken = loadToken(key: KeychainKeys.refreshToken) else {
            throw APIError(localErrorType: .tokenNotFound)
        }
    
        let router = AuthRequest.refresh(accessToken: accessToken, refreshToken: refreshToken)
  
        let data = try await networkService.fetchData(dto: AuthResponseDTO.self, router)
   
        _ = saveTokens(accessToken: data.accessToken, refreshToken: data.refreshToken)
        
    }

}
