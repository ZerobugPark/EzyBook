//
//  AppDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

final class AppDIContainer {
    
    // MARK: - Infrastructure
    private let httpClient = DefaultHttpClient()
    private let decoder = ResponseDecoder()
    private lazy var networkService = DefaultNetworkService(networkManger: httpClient, decodingManager: decoder)

    private let refreshScheduler = DefaultTokenRefreshScheduler()
    private let storage = KeyChainTokenStorage()
    private lazy var tokenService = TokenService(storage: storage, scheduler: refreshScheduler)

    // MARK: - Data Layer
    private lazy var authRepository = DefaultAuthRepository(networkService: networkService)
    private lazy var socialLoginService = DefaultsSocialLoginService()

    // MARK: - DIContainer Factory
    func makeDIContainer() -> DIContainer {
        return DIContainer(
            kakaoLoginUseCase: makeKakaoLoginUseCase(),
            createAccountUseCase: makeCreateAccountUseCase(),
            emailLoginUseCase: makeEmailLoginUseCase(),
            appleLoginUseCase: makeAppleLoginUseCase()
        )
    }
}

extension AppDIContainer {

    private func makeKakaoLoginUseCase() -> DefaultKakaoLoginUseCase {
        return DefaultKakaoLoginUseCase(
            kakoLoginService: socialLoginService,
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    private func makeAppleLoginUseCase() -> DefaultAppleLoginUseCase {
        return DefaultAppleLoginUseCase(
            appleLoginService: socialLoginService,
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    private func makeEmailLoginUseCase() -> DefaultEmailLoginUseCase {
        return DefaultEmailLoginUseCase(
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    private func makeCreateAccountUseCase() -> DefaultCreateAccountUseCase {
        return DefaultCreateAccountUseCase(authRepository: authRepository)
    }
}
