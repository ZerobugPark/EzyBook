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
//    // MARK: - Infrastructure
//    static let decoder = ResponseDecoder()
//    static let networkService = DefaultNetworkService(decodingService: decoder)
//    
//
//    static let refreshScheduler = DefaultTokenRefreshScheduler()
//    static let storage = KeyChainTokenStorage()
//    static let tokenService = DefaultTokenService(storage: storage, scheduler: refreshScheduler)
//    
//    // MARK: - Data Layer
//    static let authRepository = DefaultAuthRepository(networkService: networkService)
//    static let socialLoginService = DefaultsSocialLoginService()
//    
//    static let diContainer = DIContainer(
//        kakaoLoginUseCase: makeKakaoLoginUseCase(),
//        createAccountUseCase: makeCreateAccountUseCase(),
//        emailLoginUseCase: makeEmailLoginUseCase(),
//        appleLoginUseCase: makeAppleLoginUseCase()
//    )
//        
//    
//    static func makeLoginView(showModal: Binding<Bool> = .constant(false)) -> some View {
//        LoginView(viewModel: diContainer.makeSocialLoginViewModel())
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
//    static func makeKakaoLoginUseCase() -> DefaultKakaoLoginUseCase {
//        return DefaultKakaoLoginUseCase(
//            kakoLoginService: socialLoginService,
//            authRepository: authRepository,
//            tokenService: tokenService
//        )
//    }
//
//    static func makeAppleLoginUseCase() -> DefaultAppleLoginUseCase {
//        return DefaultAppleLoginUseCase(
//            appleLoginService: socialLoginService,
//            authRepository: authRepository,
//            tokenService: tokenService
//        )
//    }
//
//    static func makeEmailLoginUseCase() -> DefaultEmailLoginUseCase {
//        return DefaultEmailLoginUseCase(
//            authRepository: authRepository,
//            tokenService: tokenService
//        )
//    }
//
//    static func makeCreateAccountUseCase() -> DefaultCreateAccountUseCase {
//        return DefaultCreateAccountUseCase(authRepository: authRepository)
//    }
//
//}

#endif
