//
//  DefaultLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

/// 이건 추상화를 어떻게 해줘야 하나..?
final class DefaultLoginUseCase {
    
    private let loginUseCase: LoginUseCase
    private let EzyBookAuthNetworkRepository: AuthNetworkRepository
    
    init(loginUseCase: LoginUseCase, EzyBookAuthNetworkRepository: AuthNetworkRepository) {
        self.loginUseCase = loginUseCase
        self.EzyBookAuthNetworkRepository = EzyBookAuthNetworkRepository
    }
    
    
}
