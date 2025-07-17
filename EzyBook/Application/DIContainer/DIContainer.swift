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
    private let socialLoginUseCases: SocialLoginUseCases
    private let createAccountUseCase : DefaultCreateAccountUseCase
    private let emailLoginUseCase : DefaultEmailLoginUseCase

    
    
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
    let profileImageUpLoadUseCase: DefaultUploadProfileFileUseCase
    let profileModifyUseCase: DefaultProfileModifyUseCase
    let profileSearchUseCase: DefaultProfileSearchUseCase
    let reviewImageUploadUseCase: DefaultUploadReviewImages
    let reviewWriteUseCase: DefaultReViewWriteUseCase
    
    /// Order
    let orderCreateUseCase: DefaultCreateOrderUseCase
    let orderListLookUpUseCase: DefaultOrderListLookupUseCase
    
    /// Payment
    let paymentValidationUseCase: DefaultPaymentValidationUseCase

    /// Chat
    let createChatRoomUseCase: DefaultCreateChatRoomUseCase
    let chatRoomUseCases: ChatRoomListUseCases
    let chatUseCases: ChatListUseCases
    
    /// Common
    let imageLoader: DefaultLoadImageUseCase
    let viewLoader: VideoLoaderDelegate
    let tokenService: DefaultTokenService // 리프레시 갱신 시점 때문에 DI에서 추가 관리
    let socketService: SocketServicePool
    
    init(socialLoginUseCases: SocialLoginUseCases, createAccountUseCase: DefaultCreateAccountUseCase, emailLoginUseCase: DefaultEmailLoginUseCase, activityListUseCase: DefaultActivityListUseCase, activityNewListUseCase: DefaultNewActivityListUseCase, activitySearchUseCase: DefaultActivitySearchUseCase, activityDetailUseCase: DefaultActivityDetailUseCase, activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase, reviewLookupUseCase: DefaultReviewLookUpUseCase, profileLookUpUseCase: DefaultProfileLookUpUseCase, profileImageUpLoadUseCase: DefaultUploadProfileFileUseCase, profileModifyUseCase: DefaultProfileModifyUseCase, profileSearchUseCase: DefaultProfileSearchUseCase, reviewImageUploadUseCase: DefaultUploadReviewImages, reviewWriteUseCase: DefaultReViewWriteUseCase, orderCreateUseCase: DefaultCreateOrderUseCase, orderListLookUpUseCase: DefaultOrderListLookupUseCase, paymentValidationUseCase: DefaultPaymentValidationUseCase, createChatRoomUseCase: DefaultCreateChatRoomUseCase, chatRoomUseCases: ChatRoomListUseCases, chatUseCases: ChatListUseCases, imageLoader: DefaultLoadImageUseCase, viewLoader: VideoLoaderDelegate, tokenService: DefaultTokenService, socketService: SocketServicePool) {
        self.socialLoginUseCases = socialLoginUseCases
        self.createAccountUseCase = createAccountUseCase
        self.emailLoginUseCase = emailLoginUseCase
        self.activityListUseCase = activityListUseCase
        self.activityNewListUseCase = activityNewListUseCase
        self.activitySearchUseCase = activitySearchUseCase
        self.activityDetailUseCase = activityDetailUseCase
        self.activityKeepCommandUseCase = activityKeepCommandUseCase
        self.reviewLookupUseCase = reviewLookupUseCase
        self.profileLookUpUseCase = profileLookUpUseCase
        self.profileImageUpLoadUseCase = profileImageUpLoadUseCase
        self.profileModifyUseCase = profileModifyUseCase
        self.profileSearchUseCase = profileSearchUseCase
        self.reviewImageUploadUseCase = reviewImageUploadUseCase
        self.reviewWriteUseCase = reviewWriteUseCase
        self.orderCreateUseCase = orderCreateUseCase
        self.orderListLookUpUseCase = orderListLookUpUseCase
        self.paymentValidationUseCase = paymentValidationUseCase
        self.createChatRoomUseCase = createChatRoomUseCase
        self.chatRoomUseCases = chatRoomUseCases
        self.chatUseCases = chatUseCases
        self.imageLoader = imageLoader
        self.viewLoader = viewLoader
        self.tokenService = tokenService
        self.socketService = socketService
    }
}


// MARK:  Payment
extension DIContainer {
    func makePaymentViewModel() -> PaymentViewModel {
        PaymentViewModel(vaildationUseCase: paymentValidationUseCase)
    }
}


// MARK: Order
extension DIContainer {
    func makeOrderListViewModel() -> OrderListViewModel {
        OrderListViewModel(imageLoader: imageLoader)
    }
}

// MARK: Chat
extension DIContainer {
    func makeChatRoomViewModel(roomID: String, opponentNick: String) -> ChatRoomViewModel {
        let socketService: SocketService = socketService.service(for: roomID)
        return ChatRoomViewModel(
            socketService: socketService,
            roomID: roomID,
            opponentNick: opponentNick,
            chatUseCases: chatUseCases,
            profileLookUpUseCase: profileLookUpUseCase,
            profileSearchUseCase: profileSearchUseCase,
            imageLoader: imageLoader
        )
    }
    
    func makeChatRoomListViewModel() -> ChatListViewModel {
        ChatListViewModel(
            chatRoomUseCases: chatRoomUseCases,
            profileLookUpUseCase: profileLookUpUseCase,
            profileSearchUseCase: profileSearchUseCase,
            imageLoader: imageLoader
        )
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
    
    func makeProfileSupplementaryViewModel() -> ProfileSupplementaryViewModel {
        ProfileSupplementaryViewModel(orderListUseCase: orderListLookUpUseCase)
    }
    
    func makeWriteReviewViewModel() -> WriteReviewViewModel {
        WriteReviewViewModel(
            reviewImageUploadUseCase: reviewImageUploadUseCase,
            reviewWriteUseCase: reviewWriteUseCase
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
            
            socialLoginUseCases: socialLoginUseCases)
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
            createChatRoomUseCase: createChatRoomUseCase,
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
