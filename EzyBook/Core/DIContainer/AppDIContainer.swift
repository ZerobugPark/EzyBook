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
    private lazy var  networkRepository = NetworkRepository(networkManger: networkManger, decodingManager: decoder)
    
    func makeDIContainer() -> DIContainer {
        let tokenManger =  makeTokenManger()
        return DIContainer(
            networkRepository: networkRepository,
            tokenManager: tokenManger
        )
    }
}

extension AppDIContainer {
    
    private func makeTokenManger() -> TokenManager {
        let keychainHelper = KeyChainHelper()
        let tokenRepository = KeychainTokenRepository(keyChainManger: keychainHelper)
        let saveToeknUseCase = DefaultSaveTokenUseCase(tokenRepository: tokenRepository)
        let loadTokenUseCase = DefaultLoadTokenUseCase(tokenRepository: tokenRepository)
        let deleteTokenUseCase = DefaultDeleteTokenUseCase(tokenRepository: tokenRepository)
        
        return TokenManager(
            saveTokenUseCase: saveToeknUseCase,
            loadTokenUseCase: loadTokenUseCase,
            deleteTokenUseCase: deleteTokenUseCase, networkRepository: networkRepository
        )
    }
}
