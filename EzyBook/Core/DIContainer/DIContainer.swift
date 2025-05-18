//
//  DIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

///
/// 공통 모듈
/// 네트워크 서비스?, 저장소 패턴, 또 뭐가 있을끼?

final class DIContainer: ObservableObject {

    private let networkRepository: EzyBookNetworkRepository
    private let tokenManager: TokenManager
    
    init(networkRepository: EzyBookNetworkRepository, tokenManager: TokenManager) {
        self.networkRepository = networkRepository
        self.tokenManager = tokenManager
        
    }
        
}

// MARK: Make ViewModel
extension DIContainer {
    func makeAccountViewModel() -> CreateAccountViewModel {
        return CreateAccountViewModel(newtworkRepository: networkRepository)
    }
    
    func makeEmailLoginViewModel() -> EmailLoginViewModel {
        return EmailLoginViewModel(newtworkRepository: networkRepository, tokenManager: tokenManager)
    }
    
}
