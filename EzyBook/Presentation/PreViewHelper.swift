//
//  PreViewHelper.swift
//  EzyBook
//
//  Created by youngkyun park on 5/17/25.
//

import SwiftUI
#if DEBUG
//enum PreViewHelper {
//    
//    static let networkManger = DefaultNetworkManager()
//    static let decoder = ResponseDecoder()
//    static let networkRepository = DefaultNetworkRepository(networkManger: networkManger, decodingManager: decoder)
//
//    static let refreshScheduler = DefaultTokenRefreshScheduler()
//    static let tokenManger =  makeTokenManger()
//    
//    static let authNetworkRepository = DefaultAuthNetworkRepository(tokenManager: tokenManger, networkManager: networkRepository, refreshScheduler: refreshScheduler)
//    
//    static let diContainer = DIContainer(
//        socialUseCase: makeSocialUsecase(),
//        emailLoginUseCase: makeEmailUsecase(),
//        createAccounUseCase: makeCreateAcctounUsecase()
//    )
//        
//    
//    static func makeLoginView(showModal: Binding<Bool> = .constant(false)) -> some View {
//        LoginView(showModal: showModal, viewModel: diContainer.makeSocialLoginViewModel())
//            .environmentObject(diContainer)
//    }
//    
//    static func makeCreateAccountView(selectedIndex: Binding<Int> = .constant(1)) -> some View {
//        CreateAccountView(selectedIndex: selectedIndex, viewModel: diContainer.makeAccountViewModel())
//    }
//    
//    static func makeEmailLoginView(selectedIndex: Binding<Int> = .constant(0)) -> some View {
//        EmailLoginView(selectedIndex: selectedIndex, viewModel: diContainer.makeEmailLoginViewModel())
//            .environmentObject(diContainer)
//    }
//    
//    static func makeLoginSignUpPagerView() -> some View {
//        LoginSignUpPagerView()
//            .environmentObject(diContainer)
//    }
//}
//
//extension PreViewHelper {
//    
//    static func makeTokenManger() -> TokenManager {
//        let keychainManager = KeyChainTokenStorage()
//        let tokenRepository = DefaultKeychainTokenRepository(keyChainManger: keychainManager)
//        let saveToeknUseCase = DefaultSaveTokenUseCase(tokenRepository: tokenRepository)
//        let loadTokenUseCase = DefaultLoadTokenUseCase(tokenRepository: tokenRepository)
//        let deleteTokenUseCase = DefaultDeleteTokenUseCase(tokenRepository: tokenRepository)
//        
//        return TokenManager(
//            saveTokenUseCase: saveToeknUseCase,
//            loadTokenUseCase: loadTokenUseCase,
//            deleteTokenUseCase: deleteTokenUseCase)
//    }
//    
//    static func makeSocialUsecase() -> DefaultSocialLoginUseCase {
//        
//        let kakaoProvider = DefaultsSocialLoginService()
//        let appleLoginRepository = DefaultAppleLoginService()
//    
//        let useCase = DefaultSocialLoginUseCase(
//            kakaLoginProvider: kakaoProvider,
//            appleLoginRepository: appleLoginRepository,
//            authNetworkRepository: authNetworkRepository
//        )
//        
//        return useCase
//    }
//    
//    static func makeEmailUsecase() -> DefaultLoginUseCase {
//        let useCase = DefaultLoginUseCase(
//            authNetworkRepository: authNetworkRepository
//        )
//        return useCase
//    }
//    
//    static func makeCreateAcctounUsecase() -> DefaultCreateAccountUseCase {
//        let useCase = DefaultCreateAccountUseCase(networkManager: networkRepository)
//        return useCase
//    }
//
//}

#endif
