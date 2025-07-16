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
    
    private lazy var sockService = SocketServicePool(keyChain: storage)
                                                            
    // MARK: - Data Layer
    private let authRepository: DefaultAuthRepository
    private let socialLoginService: DefaultsSocialLoginService
    private let activityRepository: DefaultActivityRepository
    private let acitvityKeepStatusRepository: DefaultKeepStatusRepository
    private let reviewRepository: DefaultReviewRepository
    private let profileRepository: DefaultProfileRepository
    private let uploadRepository: DefaultUploadFileRepository
    private let orderRepository: DefaultOrderRepository
    private let paymentRepository: DefaultPaymentRepository
    private let chatRepository: DefaultChatRepository
    private let chatRealmListRepository: DefaultChatMessageRealmRepository
    private let chatMessageRealmRepository: DefaultChatRoomRealmRepository
    
    
    
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
        reviewRepository = DefaultReviewRepository(networkService: networkService)
        
        profileRepository = DefaultProfileRepository(networkService: networkService)
        uploadRepository = DefaultUploadFileRepository(networkService: networkService)
        orderRepository = DefaultOrderRepository(networkService: networkService)
        paymentRepository = DefaultPaymentRepository(networkService: networkService)
        
        chatRepository = DefaultChatRepository(networkService: networkService)

        chatRealmListRepository = DefaultChatMessageRealmRepository()
        chatMessageRealmRepository = DefaultChatRoomRealmRepository()
        
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
            profileSearchUseCase: makeProfileSearchUseCase(),
            reviewImageUploadUseCase: makeReviewImageUpload(),
            reviewWriteUseCase: makeReviewWirteUseCase(),
            orderCreateUseCase: makeOoderCreateUseCase(),
            orderListLookUpUseCase: makeOrderListLookUpUseCase(),
            paymentValidationUseCase: makePaymentVaildationUseCase(),
            createChatRoomUseCase: makeCreateChatRoomUseCase(),
            chatRoomListUseCase: makeChatRoomListUseCase(),
            chatListUseCase: makeChatListUseCase(),
            chatRoomRealmListUseCase: makeChatRoomRealmListUseCase(),
            chatRealmUseCase: makeKhatLosdUseCase(),
            chatUseCase: makeChatUseCase(),
            imageLoader: makeImageLoaderUseCase(),
            viewLoader: makeVidoeLoaderDelegate(),
            tokenService: tokenService,
            socketService: sockService
        )
    }
    

}

// MARK: Order
extension AppDIContainer {
    private func makePaymentVaildationUseCase() -> DefaultPaymentValidationUseCase {
        DefaultPaymentValidationUseCase(repo: paymentRepository)
    }
    
    private func makeOoderCreateUseCase() -> DefaultCreateOrderUseCase {
        DefaultCreateOrderUseCase(repo: orderRepository)
    }
    
    private func makeOrderListLookUpUseCase() -> DefaultOrderListLookupUseCase {
        DefaultOrderListLookupUseCase(repo: orderRepository)
    }
    
}

// MARK: Chat

extension AppDIContainer {
    private func makeCreateChatRoomUseCase() -> DefaultCreateChatRoomUseCase {
        DefaultCreateChatRoomUseCase(repo: chatRepository)
    }
    
    private func makeChatListUseCase() -> DefaultChatListUseCase {
        DefaultChatListUseCase(repo: chatRepository)
    }
    
    private func makeKhatLosdUseCase() -> DefaultChatRealmUseCase {
        DefaultChatRealmUseCase(repo: chatRealmListRepository)
    }
    
    private func makeChatRoomListUseCase() -> DefaultChatRoomListUseCase {
        DefaultChatRoomListUseCase(repo: chatRepository)
    }
    
    private func makeChatRoomRealmListUseCase() -> DefaultChatRoomRealmListUseCase {
        DefaultChatRoomRealmListUseCase(repo: chatMessageRealmRepository)
    }
    
    private func makeChatUseCase() -> ChatUseCases {
        ChatUseCases(
            sendMessages: makeSendUseCase()
        )
    }
    
    private func makeSendUseCase() -> DefaultChatSendMessageUseCase {
        DefaultChatSendMessageUseCase(repo: chatRepository)
    }
}



// MARK: Profile
extension AppDIContainer {
    private func makeProfileLookUpUseCase() -> DefaultProfileLookUpUseCase {
        DefaultProfileLookUpUseCase(repo: profileRepository)
    }
    
    private func makeProfileUpLoadFileUseCase() -> DefaultUploadProfileFileUseCase {
        DefaultUploadProfileFileUseCase(repo: uploadRepository)
    }
    
    private func makeProfileModifyUseCase() -> DefaultProfileModifyUseCase {
        DefaultProfileModifyUseCase(repo: profileRepository)
    }
    
    private func makeProfileSearchUseCase() -> DefaultProfileSearchUseCase {
        DefaultProfileSearchUseCase(repo: profileRepository)
    }
    
    private func makeReviewWirteUseCase() -> DefaultReViewWriteUseCase {
        DefaultReViewWriteUseCase(repo: reviewRepository)
    }
    
    private func makeReviewImageUpload() -> DefaultUploadReviewImages {
        DefaultUploadReviewImages(repo: uploadRepository)
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
        DefaultReviewLookUpUseCase(repo: reviewRepository)
    }
}



