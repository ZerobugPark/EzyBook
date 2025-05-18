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
    
    
    // 토큰 상태 확인
    @Published private(set) var isAuthorized: Bool = false
    
    
    init(saveTokenUseCase: SaveTokenUseCase, loadTokenUseCase: LoadTokenUseCase, deleteTokenUseCase: DeleteTokenUseCase) {
        self.saveTokenUseCase = saveTokenUseCase
        self.loadTokenUseCase = loadTokenUseCase
        self.deleteTokenUseCase = deleteTokenUseCase
    }
    
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
