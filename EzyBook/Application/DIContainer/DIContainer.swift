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
    
    
    /// Common
    let imageLoader: DefaultLoadImageUseCase
    let viewLoader: VideoLoaderDelegate

    init(kakaoLoginUseCase: DefaultKakaoLoginUseCase, createAccountUseCase: DefaultCreateAccountUseCase, emailLoginUseCase: DefaultEmailLoginUseCase, appleLoginUseCase: DefaultAppleLoginUseCase, activityListUseCase: DefaultActivityListUseCase, activityNewListUseCase: DefaultNewActivityListUseCase, activitySearchUseCase: DefaultActivitySearchUseCase, activityDetailUseCase: DefaultActivityDetailUseCase, activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase, reviewLookupUseCase: DefaultReviewLookUpUseCase, profileLookUpUseCase: DefaultProfileLookUpUseCase, profileImageUpLoadUseCase: DefaultUploadFileUseCase, imageLoader: DefaultLoadImageUseCase, viewLoader: VideoLoaderDelegate) {
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
        self.imageLoader = imageLoader
        self.viewLoader = viewLoader
    }
}

// MARK: ProfileViewModel
extension DIContainer {
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            profileLookUpUseCase: profileLookUpUseCase,
            imageLoader: imageLoader,
            uploadImageUsecase: profileImageUpLoadUseCase
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
            imageLoader: imageLoader
        )
    }

    
}
