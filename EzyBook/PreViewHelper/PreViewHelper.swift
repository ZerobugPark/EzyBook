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
    
    static let imageCache = ImageMemoryCache()
    
    static let imageLoader = DefaultImageLoader(tokenService: tokenService, imageCache: imageCache, interceptor: interceptor)
    
    static let authRepository = DefaultAuthRepository(networkService: networkService)
    static let socialLoginService = DefaultsSocialLoginService()
    
    static let activityRepository = DefaultActivityRepository(networkService: networkService)
    
    static let newActivityRepository = DefaultActivityRepository(networkService: networkService)
    static let acitvityKeepStatusRepository =  DefaultKeepStatusRepository(networkService: networkService)
    // MARK: - Data Layer
    
    static let diContainer = DIContainer(
        kakaoLoginUseCase: makeKakaoLoginUseCase(),
        createAccountUseCase: makeCreateAccountUseCase(),
        emailLoginUseCase: makeEmailLoginUseCase(),
        appleLoginUseCase: makeAppleLoginUseCase(),
        activityListUseCase: makeActivityListUseCase(),
        activityNewListUseCase: makeActivityNewListUseCase(),
        activitySearchUseCase: makeActivitySearchUseCase(),
        activityDetailUseCase: makeActivityDetailUseCase(),
        activityKeepCommandUseCase: makeActivityKeepCommandUseCase(),
        imageLoader: makeImageLoaderUseCase()
    )
    
    
    static func makeImageLoaderUseCase() -> DefaultLoadImageUseCase {
        DefaultLoadImageUseCase(imageLoader: imageLoader)
    }

    
    static func makeMainTabView() -> some View {
        MainTabView()
            .environmentObject(diContainer)
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
        DefaultNewActivityListUseCase(repo: activityRepository)
    }
    
    static func makeActivitySearchUseCase() -> DefaultActivitySearchUseCase {
        DefaultActivitySearchUseCase(repo: activityRepository)
    }
    
    static func makeActivityDetailUseCase() -> DefaultActivityDetailUseCase {
        DefaultActivityDetailUseCase(repo: activityRepository)
    }
    
    static func makeActivityKeepCommandUseCase() -> DefaultActivityKeepCommandUseCase {
        DefaultActivityKeepCommandUseCase(repo: acitvityKeepStatusRepository)
    }
    

}

#endif
