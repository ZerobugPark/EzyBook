//
//  AppDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

final class AppDIContainer {
    
    // MARK: - Infrastructure
    private let decoder = ResponseDecoder()
    private let storage = KeyChainTokenStorage()
    
    private let tokenNetworkService: DefaultNetworkService // 토큰 전용 네트워크 서비스
    private let tokenService: DefaultTokenService
    private let interceptor: TokenInterceptor
    private let networkService: DefaultNetworkService
    private let imageLoader: DefaultImageLoader
    private let imageCache: ImageCache
                                                            
    // MARK: - Data Layer
    private let authRepository: DefaultAuthRepository
    private let socialLoginService: DefaultsSocialLoginService
    private let activityRepository: DefaultActivityRepository
    private let acitvityKeepStatusRepository: DefaultKeepStatusRepository
    private let reviewRatingLookUpRepository: DefaultReviewRepository
    private let profileRepository: DefaultProfileRepository
    private let uploadRepository: DefaultUploadFileRepository
    private let orderRepository: DefaultOrderRepository
    private let paymentRepository: DefaultPaymentRepository
    
    init() {
        tokenNetworkService = DefaultNetworkService(decodingService: decoder, interceptor: nil)
        /// 어차피 액세스 토큰 갱신이기 때문에, 내부에처  헤더값이랑 같이 보내주면 됨 (즉, 이 때는 인터셉터를 쓸 필요가 없음)
        tokenService = DefaultTokenService(storage: storage, networkService: tokenNetworkService)
        interceptor = TokenInterceptor(tokenService: tokenService)
        networkService = DefaultNetworkService(decodingService: decoder, interceptor: interceptor)
        
        authRepository = DefaultAuthRepository(networkService: networkService)
        socialLoginService = DefaultsSocialLoginService()
        
        activityRepository = DefaultActivityRepository(networkService: networkService)
        acitvityKeepStatusRepository = DefaultKeepStatusRepository(networkService: networkService)
        reviewRatingLookUpRepository = DefaultReviewRepository(networkService: networkService)
        
        profileRepository = DefaultProfileRepository(networkService: networkService)
        uploadRepository = DefaultUploadFileRepository(networkService: networkService)
        orderRepository = DefaultOrderRepository(networkService: networkService)
        paymentRepository = DefaultPaymentRepository(networkService: networkService)
        
        imageCache = ImageCache()
        imageLoader = DefaultImageLoader(tokenService: tokenService, imageCache: imageCache, interceptor: interceptor)
        
    }
    
    
    // MARK: - DIContainer Factory
    func makeDIContainer() -> DIContainer {
        DIContainer(
            kakaoLoginUseCase: makeKakaoLoginUseCase(),
            createAccountUseCase: makeCreateAccountUseCase(),
            emailLoginUseCase: makeEmailLoginUseCase(),
            appleLoginUseCase: makeAppleLoginUseCase(),
            activityListUseCase: makeActivityListUseCase(),
            activityNewListUseCase: makeActivityNewListUseCase(),
            activitySearchUseCase: makeActivitySearchUseCase(),
            activityDetailUseCase: makeActivityDetailUseCase(),
            activityKeepCommandUseCase: makeActivityKeepCommandUseCase(),
            reviewLookupUseCase: makeReviewRatingUseCase(),
            profileLookUpUseCase: makeProfileLookUpUseCase(),
            profileImageUpLoadUseCase: makeProfileUpLoadFileUseCase(),
            profileModifyUseCase: makeProfileModifyUseCase(),
            orderCreateUseCase: makeOoderCreateUseCase(),
            orderListLookUpUseCase: makeOrderListLookUpUseCase(),
            paymentValidationUseCase: makePaymentVaildationUseCase(),
            imageLoader: makeImageLoaderUseCase(),
            viewLoader: makeVidoeLoaderDelegate(),
            tokenService: tokenService
        )
    }
    

}

// MARK: Order
extension AppDIContainer {
    private func makePaymentVaildationUseCase() -> DefaultPaymentValidationUseCase {
        DefaultPaymentValidationUseCase(repo: paymentRepository)
    }
    
}


// MARK: Order
extension AppDIContainer {
    private func makeOoderCreateUseCase() -> DefaultCreateOrderUseCase {
        DefaultCreateOrderUseCase(repo: orderRepository)
    }
    
    private func makeOrderListLookUpUseCase() -> DefaultOrderListLookupUseCase {
        DefaultOrderListLookupUseCase(repo: orderRepository)
    }
}


// MARK: Profile
extension AppDIContainer {
    private func makeProfileLookUpUseCase() -> DefaultProfileLookUpUseCase {
        DefaultProfileLookUpUseCase(repo: profileRepository)
    }
    
    private func makeProfileUpLoadFileUseCase() -> DefaultUploadFileUseCase {
        DefaultUploadFileUseCase(repo: uploadRepository)
    }
    
    private func makeProfileModifyUseCase() -> DefaultProfileModifyUseCase {
        DefaultProfileModifyUseCase(repo: profileRepository)
    }
    
}


// MARK: Common
extension AppDIContainer {
    private func makeImageLoaderUseCase() -> DefaultLoadImageUseCase {
        DefaultLoadImageUseCase(imageLoader: imageLoader)
    }
    
    
    private func makeVidoeLoaderDelegate() -> VideoLoaderDelegate {
        VideoLoaderDelegate(
            tokenService: tokenService,
            interceptor: interceptor
        )
    }
}



// MARK: Auth
extension AppDIContainer {

    private func makeKakaoLoginUseCase() -> DefaultKakaoLoginUseCase {
        DefaultKakaoLoginUseCase(
            kakoLoginService: socialLoginService,
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    private func makeAppleLoginUseCase() -> DefaultAppleLoginUseCase {
        DefaultAppleLoginUseCase(
            appleLoginService: socialLoginService,
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    private func makeEmailLoginUseCase() -> DefaultEmailLoginUseCase {
        DefaultEmailLoginUseCase(
            authRepository: authRepository,
            tokenService: tokenService
        )
    }

    private func makeCreateAccountUseCase() -> DefaultCreateAccountUseCase {
        DefaultCreateAccountUseCase(authRepository: authRepository)
    }
}


// MARK: Activity
extension AppDIContainer {

    private func makeActivityListUseCase() -> DefaultActivityListUseCase {
        DefaultActivityListUseCase(repo: activityRepository)
    }

    private func makeActivityNewListUseCase() -> DefaultNewActivityListUseCase {
        DefaultNewActivityListUseCase(repo: activityRepository)
    }
    
    private func makeActivitySearchUseCase() -> DefaultActivitySearchUseCase {
        DefaultActivitySearchUseCase(repo: activityRepository)
    }
    
    private func makeActivityDetailUseCase() -> DefaultActivityDetailUseCase {
        DefaultActivityDetailUseCase(repo: activityRepository)
    }
    
    private func makeActivityKeepCommandUseCase() -> DefaultActivityKeepCommandUseCase {
        DefaultActivityKeepCommandUseCase(repo: acitvityKeepStatusRepository)
    }
    

}

// MARK: Review
extension AppDIContainer {
    
    private func makeReviewRatingUseCase() -> DefaultReviewLookUpUseCase {
        DefaultReviewLookUpUseCase(repo: reviewRatingLookUpRepository)
    }
}



