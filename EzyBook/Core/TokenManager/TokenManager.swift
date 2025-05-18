//
//  TokenManager.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import SwiftUI

/// 토근 관련 매니저 (저장, 갱신 등)
final class TokenManager: ObservableObject {
    
    private let saveTokenUseCase: SaveTokenUseCase
    private let loadTokenUseCase: LoadTokenUseCase
    private let deleteTokenUseCase: DeleteTokenUseCase
    private let networkRepository: EzyBookNetworkRepository
    
    // 토큰 상태 확인, 상태에따른 화면 표시 필요
    @Published private(set) var isAuthorized: Bool = false
    
    private var timer: DispatchSourceTimer?
    private let refreshInterval: TimeInterval = 115 * 60 // 115분마다 갱신 (120분마다 갱신)
    
    
    init(saveTokenUseCase: SaveTokenUseCase, loadTokenUseCase: LoadTokenUseCase, deleteTokenUseCase: DeleteTokenUseCase, networkRepository: EzyBookNetworkRepository) {
        self.saveTokenUseCase = saveTokenUseCase
        self.loadTokenUseCase = loadTokenUseCase
        self.deleteTokenUseCase = deleteTokenUseCase
        self.networkRepository = networkRepository
    }
    
    //토큰에 개발저장이 필요하다면 (확장성 고려)
    func saveToken(key: String, value: String) -> Bool {
        let result =  saveTokenUseCase(key: key,value: value)
        if result {
            isAuthorized = true
            return true
        } else {
            isAuthorized = false
            return false
        }
    }
    
    func saveTokens(accessToken: String, refreshToken: String) -> Bool {
        let accessSaved = saveToken(key: KeyChainManger.accessToken, value: accessToken)
        let refreshSaved = saveToken(key: KeyChainManger.refreshToken, value: refreshToken)
        
        isAuthorized = accessSaved && refreshSaved
        
        if isAuthorized {
            startTokenRefresh()
        }
        
        return isAuthorized
    }
    
    
    func loadToken(key: String) -> String? {
        loadTokenUseCase(key: key)
    }
    
    func deleteToken(key: String) -> Bool {
        let result =  deleteTokenUseCase(key: key)
        isAuthorized = false
        if result {
            return true
        } else {
            return false
        }
    }
    
}

extension TokenManager {
    
    private func startTokenRefresh() {
        stopTokenRefresh() // 중복 방지
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now() + refreshInterval, repeating: refreshInterval)
        
        timer.setEventHandler { [weak self] in
            self?.refreshToken()
        }
        
        self.timer = timer
        timer.resume()
    }
    
    private func stopTokenRefresh() {
        timer?.cancel()
        timer = nil
    }
    
    private func refreshToken() {
        
        guard let accessToken = loadToken(key: KeyChainManger.accessToken),
              let refreshToken = loadToken(key: KeyChainManger.refreshToken) else {
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
            return
        }
        
        let router = AuthRequest.refresh(accessToken: accessToken, refreshToken: refreshToken)
        
        networkRepository.fetchData(dto: AuthResponseDTO.self, router) { [weak self] (result: Result<RefreshEntity, APIError>) in
            
            guard let self = self else { return }
            switch result {
            case .success(let success):
                print("Refresh success")
                _ = self.saveTokens(accessToken: success.accessToken, refreshToken: success.refreshToken)
            case .failure(let failure):
                print("Refresh failed: \(failure)")
                DispatchQueue.main.async {
                    self.isAuthorized = false
                }
            }
            
        }
    }
    
}
