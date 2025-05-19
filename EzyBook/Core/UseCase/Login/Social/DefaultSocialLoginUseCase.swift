//
//  DefaultSocialLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation
import Combine


final class DefaultSocialLoginUseCase {
    
    // 여기는 카카오 로그인과, apple 로그인이 필요
    private let kakaLoginProvider: SocialLoginProvider
    private let appleLoginRepository: SocialLoginProvider
    private let authNetworkRepository: AuthNetworkRepository
    
    // ViewModel이 구독할 상태
    //let authUIState = CurrentValueSubject<AuthUIState, Never>(.idle)
    
    //private var cancellables = Set<AnyCancellable>()
    
    init(kakaLoginProvider: SocialLoginProvider, appleLoginRepository: SocialLoginProvider, authNetworkRepository: AuthNetworkRepository) {
        self.kakaLoginProvider = kakaLoginProvider
        self.appleLoginRepository = appleLoginRepository
        self.authNetworkRepository = authNetworkRepository
    }
    
    
}

// MARK: Login
extension DefaultSocialLoginUseCase {
    
    func kakaoLogin(completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        Task {
            do {
                let data = try await kakaLoginProvider.login()
                try await authNetworkRepository.kakoLogin(data)
                
                completionHandler(.success(()))
            } catch  {
                if let apiError = error as? APIError {
                    completionHandler(.failure(apiError))
                } else {
                    completionHandler(.failure(APIError(type: .unknown)))
                }
            }
        }
    }
    
    
    func appleLogin() {
        
    }
    
}
