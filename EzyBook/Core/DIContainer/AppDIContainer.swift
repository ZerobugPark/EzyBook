//
//  AppDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

final class AppDIContainer {
    
    private let networkManger = NetworkService()
    private let decoder = ResponseDecoder()
    private lazy var networkRepository = NetworkRepository(networkManger: networkManger, decodingManager: decoder)

    private let refreshScheduler = DefaultTokenRefreshScheduler()
    private lazy var tokenManger =  makeTokenManger()
    
    private lazy var authNetworkRepository = DefaultAuthNetworkRepository(tokenManager: tokenManger, networkManager: networkRepository, refreshScheduler: refreshScheduler)
    
    
    
    func makeDIContainer() -> DIContainer {
        
        let socialUseCase = makeSocialUsecase()
        let emailUseCase = makeEmailUsecase()
        
        return DIContainer(socialUseCase: socialUseCase, emailLoginUseCase: emailUseCase)
        
    }
}

extension AppDIContainer {
    
 
    
    private func makeTokenManger() -> TokenManager {
        let keychainManager = KeyChainManager()
        let tokenRepository = KeychainTokenRepository(keyChainManger: keychainManager)
        let saveToeknUseCase = DefaultSaveTokenUseCase(tokenRepository: tokenRepository)
        let loadTokenUseCase = DefaultLoadTokenUseCase(tokenRepository: tokenRepository)
        let deleteTokenUseCase = DefaultDeleteTokenUseCase(tokenRepository: tokenRepository)
        
        return TokenManager(
            saveTokenUseCase: saveToeknUseCase,
            loadTokenUseCase: loadTokenUseCase,
            deleteTokenUseCase: deleteTokenUseCase, networkRepository: networkRepository
        )
    }
    
    private func makeSocialUsecase() -> DefaultSocialLoginUseCase {
        
        let kakaoProvider = KaKaoLoginProvider()
        let appleLoginRepository = AppleLoginProvider()
    
        let socialUseCase = DefaultSocialLoginUseCase(kakaLoginProvider: kakaoProvider, appleLoginRepository: appleLoginRepository, authNetworkRepository: authNetworkRepository)
        
        return socialUseCase
    }
    
    private func makeEmailUsecase() -> DefaultLoginUseCase {
        let emailUseCase = DefaultLoginUseCase(authNetworkRepository: authNetworkRepository)
        return emailUseCase
    }
}
