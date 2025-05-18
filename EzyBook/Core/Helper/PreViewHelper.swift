//
//  PreViewHelper.swift
//  EzyBook
//
//  Created by youngkyun park on 5/17/25.
//

import SwiftUI

enum PreViewHelper {
    
    static let networkManger = NetworkService()
    static let decoder = ResponseDecoder()
    static let networkRepository = NetworkRepository(networkManger: networkManger, decodingManager: decoder)
    static let kaKaoLoginRepository = KaKaoLoginRepository(networkRepository: networkRepository, tokenManager: makeTokenManger())
    static let kakaoLoginUseCase = DefaultKakaoLoginUseCase(kakoLoginRepository: kaKaoLoginRepository)
    
    static let diContainer = DIContainer(
        networkRepository: networkRepository,
        tokenManager: makeTokenManger(),
        kakaoLoginUseCase: kakaoLoginUseCase
    )
    static func makeLoginView(showModal: Binding<Bool> = .constant(false)) -> some View {
        LoginView(showModal: showModal)
            .environmentObject(diContainer)
    }
    
    static func makeCreateAccountView(selectedIndex: Binding<Int> = .constant(1)) -> some View {
        CreateAccountView(selectedIndex: selectedIndex, viewModel: diContainer.makeAccountViewModel())
    }
    
    static func makeEmailLoginView(selectedIndex: Binding<Int> = .constant(0)) -> some View {
        EmailLoginView(selectedIndex: selectedIndex, viewModel: diContainer.makeEmailLoginViewModel())
            .environmentObject(diContainer)
    }
    
    static func makeLoginSignUpPagerView() -> some View {
        LoginSignUpPagerView()
            .environmentObject(diContainer)
    }
}

extension PreViewHelper {
    static func makeTokenManger() -> TokenManager {
        let keychainHelper = KeyChainHelper()
        let tokenRepository = KeychainTokenRepository(keyChainManger: keychainHelper)
        let saveToeknUseCase = DefaultSaveTokenUseCase(tokenRepository: tokenRepository)
        let loadTokenUseCase = DefaultLoadTokenUseCase(tokenRepository: tokenRepository)
        let deleteTokenUseCase = DefaultDeleteTokenUseCase(tokenRepository: tokenRepository)
        
        return TokenManager(
            saveTokenUseCase: saveToeknUseCase,
            loadTokenUseCase: loadTokenUseCase,
            deleteTokenUseCase: deleteTokenUseCase,
            networkRepository: networkRepository
        )
    }
}

