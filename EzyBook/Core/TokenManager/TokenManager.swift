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
    
    
    // 토큰 상태 확인
    @Published private(set) var isAuthorized: Bool = false
    
    
    init(saveTokenUseCase: SaveTokenUseCase) {
        self.saveTokenUseCase = saveTokenUseCase
    }
    
    func saveTokens(key: String, value: String) -> Bool {
        let result =  saveTokenUseCase(key: key, value: value)
        if result {
            isAuthorized = true
            return true
        } else {
            isAuthorized = false
            return false
        }
         
     }
    
}
