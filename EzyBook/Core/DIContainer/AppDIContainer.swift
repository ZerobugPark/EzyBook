//
//  AppDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

final class AppDIContainer {
    func makeDIContainer() -> DIContainer {
        let networkManger = NetworkService()
        let decoder = ResponseDecoder()
        let tokenManger =  makeTokenManger()
        
        return DIContainer(
            networkManger: networkManger,
            decodingManger: decoder,
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
            deleteTokenUseCase: deleteTokenUseCase
        )
    }
}
