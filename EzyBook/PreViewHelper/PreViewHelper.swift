//
//  PreViewHelper.swift
//  EzyBook
//
//  Created by youngkyun park on 5/17/25.
//

import SwiftUI
#if DEBUG
enum PreViewHelper {
    
    // MARK: - Infrastructure
    static let decoder = ResponseDecoder()
    static let storage = KeyChainTokenStorage()
    
    static let tokenNetworkService = DefaultNetworkService(decodingService: decoder, interceptor: nil)
    
    static let tokenService = DefaultTokenService(storage: storage, networkService: tokenNetworkService)
    
    
    static let interceptor = TokenInterceptor(tokenService: tokenService)
    static let  networkService = DefaultNetworkService(decodingService: decoder, interceptor: interceptor)
    
    static let  authRepository = DefaultAuthRepository(networkService: networkService)
    static let  socialLoginService = DefaultsSocialLoginService()
    
    static let  activityRepository = DefaultActivityRepository(networkService: networkService)
    
    static let  newActivityRepository = DefaultActivityRepository(networkService: networkService)
    
    // MARK: - Data Layer
    
    static let diContainer = DIContainer(
        kakaoLoginUseCase: makeKakaoLoginUseCase(),
        createAccountUseCase: makeCreateAccountUseCase(),
        emailLoginUseCase: makeEmailLoginUseCase(),
        appleLoginUseCase: makeAppleLoginUseCase(),
        activityListUseCase: makeActivityListUseCase(),
        activityNewListUseCase: makeActivityNewListUseCase(),
        activitySearchUseCase: makeActivityNewListUseCase()
    )
    
    static let coordinators = CoordinatorContainer()
    
    static func makeLoginView(showModal: Binding<Bool> = .constant(false)) -> some View {
        LoginView(viewModel: diContainer.makeSocialLoginViewModel())
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
    
    static func makeHomeView() -> some View {
        HomeView(viewModel: diContainer.makeHomeViewModel())
            .environmentObject(diContainer)
    }
    
    static func makeMainTabView() -> some View {
        MainTabView()
            .environmentObject(diContainer)
            .environmentObject(coordinators.makeHomeCoordinator())
    }
}

// MARK: Auth
extension PreViewHelper {
    
    static func makeKakaoLoginUseCase() -> DefaultKakaoLoginUseCase {
        return DefaultKakaoLoginUseCase(
            kakoLoginService: socialLoginService,
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    static func makeAppleLoginUseCase() -> DefaultAppleLoginUseCase {
        return DefaultAppleLoginUseCase(
            appleLoginService: socialLoginService,
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    static func makeEmailLoginUseCase() -> DefaultEmailLoginUseCase {
        return DefaultEmailLoginUseCase(
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    static func makeCreateAccountUseCase() -> DefaultCreateAccountUseCase {
        return DefaultCreateAccountUseCase(authRepository: authRepository)
    }

}

// MARK: Activity
extension PreViewHelper {

    static func makeActivityListUseCase() -> DefaultActivityListUseCase {
        DefaultActivityListUseCase(repo: activityRepository)
    }

    static func makeActivityNewListUseCase() -> DefaultNewActivityListUseCase {
        DefaultNewActivityListUseCase(repo: newActivityRepository)
    }
    
    static func makeActivityNewListUseCase() -> DefaultActivitySearchUseCase {
        DefaultActivitySearchUseCase(repo: newActivityRepository)
    }
    

}

#endif
