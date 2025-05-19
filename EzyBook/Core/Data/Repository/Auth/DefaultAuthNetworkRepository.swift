//
//  DefaultAuthNetworkRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

/// 실제 네트워크 통신 진행
final class DefaultAuthNetworkRepository: AuthNetworkRepository {
    // 통신 및 갱신 Flow 진행
    private let tokenManager: TokenManager
    private let networkManager: NetworkRepository
    private let refreshScheduler :TokenRefreshScheduler
    
    init(tokenManager: TokenManager, networkManager: NetworkRepository, refreshScheduler: TokenRefreshScheduler) {
        self.tokenManager = tokenManager
        self.networkManager = networkManager
        self.refreshScheduler = refreshScheduler
    }
    
    func kakoLogin(_ token: String) async throws {
        
        let requestDto = KakaoLoginRequestDTO(oauthToken: token, deviceToken: nil)
        let router = UserRequest.kakaoLogin(body: requestDto)
        
        let data = try await networkManager.fetchData(dto: LoginResponseDTO.self, router)
        
        _ = tokenManager.saveTokens(accessToken: data.accessToken, refreshToken: data.refreshToken)
        
        refreshScheduler.start { [weak self] in
            try? await self?.refreshTokenIfNeeded()
        }
    }

}

extension DefaultAuthNetworkRepository {
    
    private func refreshTokenIfNeeded() async throws {
     
        guard let accessToken = tokenManager.loadToken(key: KeyChainManger.accessToken),
              let refreshToken = tokenManager.loadToken(key: KeyChainManger.refreshToken) else {
            return
        }
    
        let router = AuthRequest.refresh(accessToken: accessToken, refreshToken: refreshToken)
        
        let response = try await networkManager.fetchData(dto: AuthResponseDTO.self, router)
        
        let _ = tokenManager.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
    }
    
        
}
