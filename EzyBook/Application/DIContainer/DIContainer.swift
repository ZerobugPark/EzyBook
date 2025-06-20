//
//  DIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

///
/// 공통 모듈
/// 네트워크 서비스?, 저장소 패턴, 또 뭐가 있을끼?
final class DIContainer: ObservableObject {

    /// Auth
    private let kakaoLoginUseCase: DefaultKakaoLoginUseCase
    private let createAccountUseCase : DefaultCreateAccountUseCase
    private let emailLoginUseCase : DefaultEmailLoginUseCase
    private let appleLoginUseCase: DefaultAppleLoginUseCase
    
    
    /// Activity
    let activityListUseCase: DefaultActivityListUseCase
    let activityNewListUseCase: DefaultNewActivityListUseCase
    let activitySearchUseCase: DefaultActivitySearchUseCase
    let activityDetailUseCase: DefaultActivityDetailUseCase
    let activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase
    
    
    /// Review
    let reviewLookupUseCase: DefaultReviewLookUpUseCase

    
    
    /// Profile
    let profileLookUpUseCase: DefaultProfileLookUpUseCase
    let profileImageUpLoadUseCase: DefaultUploadFileUseCase
    let profileModifyUseCase: DefaultProfileModifyUseCase
    
    /// Order
    let orderCreateUseCase: DefaultCreateOrderUseCase
    
    
    /// Payment
    let paymentValidationUseCase: DefaultPaymentValidationUseCase

    
    /// Common
    let imageLoader: DefaultLoadImageUseCase
    let viewLoader: VideoLoaderDelegate
    let tokenService: DefaultTokenService // 리프레시 갱신 시점 때문에 DI에서 추가 관리

    init(kakaoLoginUseCase: DefaultKakaoLoginUseCase, createAccountUseCase: DefaultCreateAccountUseCase, emailLoginUseCase: DefaultEmailLoginUseCase, appleLoginUseCase: DefaultAppleLoginUseCase, activityListUseCase: DefaultActivityListUseCase, activityNewListUseCase: DefaultNewActivityListUseCase, activitySearchUseCase: DefaultActivitySearchUseCase, activityDetailUseCase: DefaultActivityDetailUseCase, activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase, reviewLookupUseCase: DefaultReviewLookUpUseCase, profileLookUpUseCase: DefaultProfileLookUpUseCase, profileImageUpLoadUseCase: DefaultUploadFileUseCase, profileModifyUseCase: DefaultProfileModifyUseCase, orderCreateUseCase: DefaultCreateOrderUseCase, paymentValidationUseCase: DefaultPaymentValidationUseCase, imageLoader: DefaultLoadImageUseCase, viewLoader: VideoLoaderDelegate, tokenService: DefaultTokenService) {
        self.kakaoLoginUseCase = kakaoLoginUseCase
        self.createAccountUseCase = createAccountUseCase
        self.emailLoginUseCase = emailLoginUseCase
        self.appleLoginUseCase = appleLoginUseCase
        self.activityListUseCase = activityListUseCase
        self.activityNewListUseCase = activityNewListUseCase
        self.activitySearchUseCase = activitySearchUseCase
        self.activityDetailUseCase = activityDetailUseCase
        self.activityKeepCommandUseCase = activityKeepCommandUseCase
        self.reviewLookupUseCase = reviewLookupUseCase
        self.profileLookUpUseCase = profileLookUpUseCase
        self.profileImageUpLoadUseCase = profileImageUpLoadUseCase
        self.profileModifyUseCase = profileModifyUseCase
        self.orderCreateUseCase = orderCreateUseCase
        self.paymentValidationUseCase = paymentValidationUseCase
        self.imageLoader = imageLoader
        self.viewLoader = viewLoader
        self.tokenService = tokenService
    }
}


// MARK:  Payment
extension DIContainer {
    func makePaymentViewModl() -> PayMentViewModel {
        PayMentViewModel(vaildationUseCase: paymentValidationUseCase)
    }
}


// MARK: ProfileViewModel
extension DIContainer {
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            profileLookUpUseCase: profileLookUpUseCase,
            imageLoader: imageLoader,
            uploadImageUsecase: profileImageUpLoadUseCase,
            profileModifyUseCase: profileModifyUseCase
        )
    }
}

// MARK: Common
extension DIContainer {
    
    func makeVideoPlayerViewModel() -> VideoPlayerViewModel {
        VideoPlayerViewModel(videoLoader: viewLoader)
    }
    
    func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel {
        ZoomableImageFullScreenViewModel(imageLoader: imageLoader)
    }
}


// MARK: Make Auth ViewModel
extension DIContainer {
    func makeAccountViewModel() -> CreateAccountViewModel {
        CreateAccountViewModel(createUseCase: createAccountUseCase)
    }
    
    func makeEmailLoginViewModel() -> EmailLoginViewModel {
        EmailLoginViewModel(emailLoginUseCase: emailLoginUseCase)
    }
    
    func makeSocialLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            kakaoLoginUseCase: kakaoLoginUseCase,
            appleLoginUseCase: appleLoginUseCase
        )
    }

}

// MARK: Make Home ViewModel
extension DIContainer {
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            activityListUseCase: activityListUseCase,
            activityNewLisUseCase: activityNewListUseCase,
            activityDeatilUseCase: activityDetailUseCase,
            activityKeepCommandUseCase: activityKeepCommandUseCase,
            imageLoader: imageLoader
        )
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            activitySearchLisUseCase: activitySearchUseCase,
            activityDeatilUseCase: activityDetailUseCase,
            activityKeepCommandUseCase: activityKeepCommandUseCase,
            imageLoader: imageLoader
        )
    }
    
    func makeDetailViewModel() -> DetailViewModel {
        DetailViewModel(
            activityDeatilUseCase: activityDetailUseCase,
            activityKeepCommandUseCase: activityKeepCommandUseCase,
            reviewLookupUseCase: reviewLookupUseCase,
            orderUseCaes: orderCreateUseCase,
            imageLoader: imageLoader
        )
    }

    
}

// MARK: 토큰 갱신 추가
extension DIContainer {
    func refreshAccessTokenIfNeeded() async throws {
        try await tokenService.refreshToken()

    }
}
