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
    private lazy var networkRepository = DefaultNetworkRepository(networkManger: networkManger, decodingManager: decoder)

    private let refreshScheduler = DefaultTokenRefreshScheduler()
    private lazy var tokenManger =  makeTokenManger()
    
    private lazy var authNetworkRepository = DefaultAuthNetworkRepository(tokenManager: tokenManger, networkManager: networkRepository, refreshScheduler: refreshScheduler)
    
    
    func makeDIContainer() -> DIContainer {
        
        let socialUseCase = makeSocialUsecase()
        let emailUseCase = makeEmailUsecase()
        let createAccountUseCase = makeCreateAcctounUsecase()
        
        return DIContainer(
            socialUseCase: socialUseCase,
            emailLoginUseCase: emailUseCase,
            createAccounUseCase: createAccountUseCase
        )
        
    }
}

extension AppDIContainer {
    
    private func makeTokenManger() -> TokenManager {
        let keychainManager = KeyChainManager()
        let tokenRepository = DefaultKeychainTokenRepository(keyChainManger: keychainManager)
        let saveToeknUseCase = DefaultSaveTokenUseCase(tokenRepository: tokenRepository)
        let loadTokenUseCase = DefaultLoadTokenUseCase(tokenRepository: tokenRepository)
        let deleteTokenUseCase = DefaultDeleteTokenUseCase(tokenRepository: tokenRepository)
        
        return TokenManager(
            saveTokenUseCase: saveToeknUseCase,
            loadTokenUseCase: loadTokenUseCase,
            deleteTokenUseCase: deleteTokenUseCase)
    }
    
    private func makeSocialUsecase() -> DefaultSocialLoginUseCase {
        
        let kakaoProvider = KaKaoLoginProvider()
        let appleLoginRepository = AppleLoginProvider()
    
        let useCase = DefaultSocialLoginUseCase(
            kakaLoginProvider: kakaoProvider,
            appleLoginRepository: appleLoginRepository,
            authNetworkRepository: authNetworkRepository
        )
        
        return useCase
    }
    
    private func makeEmailUsecase() -> DefaultLoginUseCase {
        let useCase = DefaultLoginUseCase(
            authNetworkRepository: authNetworkRepository
        )
        return useCase
    }
    
    private func makeCreateAcctounUsecase() -> DefaultCreateAccountUseCase {
        let useCase = DefaultCreateAccountUseCase(networkManager: networkRepository)
        return useCase
    }
}
