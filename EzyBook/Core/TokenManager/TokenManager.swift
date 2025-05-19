//
//  TokenManager.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import SwiftUI
import Combine

enum AuthState {
    case authenticated
    case tokenRefreshed
    case tokenExpired
    case refreshFailed
}


/// 토근 관련 매니저 (저장, 갱신 등)
final class TokenManager {
    
    private let saveTokenUseCase: SaveTokenUseCase
    private let loadTokenUseCase: LoadTokenUseCase
    private let deleteTokenUseCase: DeleteTokenUseCase
    private let networkRepository: EzyBookNetworkRepository
    
    init(saveTokenUseCase: SaveTokenUseCase, loadTokenUseCase: LoadTokenUseCase, deleteTokenUseCase: DeleteTokenUseCase, networkRepository: EzyBookNetworkRepository) {
        self.saveTokenUseCase = saveTokenUseCase
        self.loadTokenUseCase = loadTokenUseCase
        self.deleteTokenUseCase = deleteTokenUseCase
        self.networkRepository = networkRepository
    }
    
    //토큰에 개발저장이 필요하다면 (확장성 고려)
    func saveToken(key: String, value: String) -> Bool {
        let result =  saveTokenUseCase(key: key,value: value)
        return result
            
    }
    
    func saveTokens(accessToken: String, refreshToken: String) -> Bool {
        let accessSaved = saveToken(key: KeyChainManger.accessToken, value: accessToken)
        let refreshSaved = saveToken(key: KeyChainManger.refreshToken, value: refreshToken)
        
        return accessSaved && refreshSaved
    }
    
    
    func loadToken(key: String) -> String? {
        loadTokenUseCase(key: key)
    }
    
    func deleteToken(key: String) -> Bool {
        let result =  deleteTokenUseCase(key: key)
        return result
    }
    
}

