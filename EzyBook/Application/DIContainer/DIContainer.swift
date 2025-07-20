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
    
    /// Token Service
    let toekenService: DefaultTokenService
    
    ///Banner
    private let bannerInfoUseCase: DefaultBannerInfoUseCase
    
    /// Activity
    private let activityListUseCase: DefaultActivityListUseCase
    private let activityNewListUseCase: DefaultNewActivityListUseCase
    private let activitySearchUseCase: DefaultActivitySearchUseCase
    private let activityDetailUseCase: DefaultActivityDetailUseCase
    private let activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase
    
    
    /// Review
    private let reviewLookupUseCase: DefaultReviewLookUpUseCase
    
    
    
    /// Profile
    private let profileLookUpUseCase: DefaultProfileLookUpUseCase
    private let profileImageUpLoadUseCase: DefaultUploadProfileFileUseCase
    private let profileModifyUseCase: DefaultProfileModifyUseCase
    private let profileSearchUseCase: DefaultProfileSearchUseCase
    private let reviewImageUploadUseCase: DefaultUploadReviewImages
    private let reviewWriteUseCase: DefaultReViewWriteUseCase
    
    /// Order
    private let orderCreateUseCase: DefaultCreateOrderUseCase
    private let orderListLookUpUseCase: DefaultOrderListLookupUseCase
    
    /// Payment
    private let paymentValidationUseCase: DefaultPaymentValidationUseCase
    
    /// Chat
    private let createChatRoomUseCase: DefaultCreateChatRoomUseCase
    private let chatRoomUseCases: ChatRoomListUseCases
    private let chatUseCases: ChatListUseCases
    
    /// Common
    let imageLoader: DefaultLoadImageUseCase
    private let videoLoader: VideoLoaderDelegate
    private let tokenService: DefaultTokenService // 리프레시 갱신 시점 때문에 DI에서 추가 관리
    private let socketService: SocketServicePool
    
    init(socialLoginUseCases: SocialLoginUseCases, createAccountUseCase: DefaultCreateAccountUseCase, emailLoginUseCase: DefaultEmailLoginUseCase, toekenService: DefaultTokenService, bannerInfoUseCase: DefaultBannerInfoUseCase, activityListUseCase: DefaultActivityListUseCase, activityNewListUseCase: DefaultNewActivityListUseCase, activitySearchUseCase: DefaultActivitySearchUseCase, activityDetailUseCase: DefaultActivityDetailUseCase, activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase, reviewLookupUseCase: DefaultReviewLookUpUseCase, profileLookUpUseCase: DefaultProfileLookUpUseCase, profileImageUpLoadUseCase: DefaultUploadProfileFileUseCase, profileModifyUseCase: DefaultProfileModifyUseCase, profileSearchUseCase: DefaultProfileSearchUseCase, reviewImageUploadUseCase: DefaultUploadReviewImages, reviewWriteUseCase: DefaultReViewWriteUseCase, orderCreateUseCase: DefaultCreateOrderUseCase, orderListLookUpUseCase: DefaultOrderListLookupUseCase, paymentValidationUseCase: DefaultPaymentValidationUseCase, createChatRoomUseCase: DefaultCreateChatRoomUseCase, chatRoomUseCases: ChatRoomListUseCases, chatUseCases: ChatListUseCases, imageLoader: DefaultLoadImageUseCase, viewLoader: VideoLoaderDelegate, tokenService: DefaultTokenService, socketService: SocketServicePool) {
        self.socialLoginUseCases = socialLoginUseCases
        self.createAccountUseCase = createAccountUseCase
        self.emailLoginUseCase = emailLoginUseCase
        self.toekenService = toekenService
        self.bannerInfoUseCase = bannerInfoUseCase
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
        self.videoLoader = viewLoader
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
            profileSearchUseCase: profileSearchUseCase,
            imageLoader: imageLoader
        )
    }
    
    func makeChatRoomListViewModel() -> ChatListViewModel {
        ChatListViewModel(
            chatRoomUseCases: chatRoomUseCases,
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
        VideoPlayerViewModel(videoLoader: videoLoader)
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

// MARK: 광고
extension DIContainer {
    func makeBannerViewModel() -> BannerViewModel {
        BannerViewModel(
            imageLoader: imageLoader,
            bannerUseCase: bannerInfoUseCase
        )
    }
}


extension DIContainer {
    
    
    // MARK: 앱 시작 시 세션 초기화 (토큰 갱신 + 유저 정보 최신화)
    func initializeAppSession() async throws {
        
        // 1) 토큰 갱신
        try await refreshAccessTokenIfNeeded()
        
        // 2) 최신 유저 정보 가져오기 (없을 경우, 기존 User 정보)
        await initializeUserSession()
        
    }
    
    // MARK: 토큰 갱신 추가
    private func refreshAccessTokenIfNeeded() async throws {
        try await tokenService.refreshToken()
    }
    
    // MARK: 서버에서 최신 유저 정보 업데이트
    private func initializeUserSession() async {
        do {
            let latestUser = try await profileLookUpUseCase.execute()
            
            let userInfo = UserEntity(
                userID: latestUser.userID,
                email: latestUser.email,
                nick: latestUser.nick
            )
            
            UserSession.shared.update(userInfo)
            
        } catch {
            print("최신 유저 정보 가져오기 실패: \(error)")
        }
    }
    
    
}
