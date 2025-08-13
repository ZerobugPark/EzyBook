//
//  HomeDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import UIKit


protocol HomeFactory {
    func makeHomeViewModel() -> HomeViewModel
    func makeDetailViewModel(id: String) -> DetailViewModel
    func makePaymentViewModel() -> PaymentViewModel
    func makeSearchViewModel() -> SearchViewModel
    func makeBannerViewModel() -> BannerViewModel
    func makeReviewViewModel(id: String) -> ReviewViewModel
    func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel
    func makeVideoPlayerViewModel() -> VideoPlayerViewModel
    func makeChatRoomViewModel(roomID: String, opponentNick: String) -> ChatRoomViewModel
}

final class HomeDIContainer {
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    private let mediaFactory: MediaFactory
    private let chatFactory: ChatFactory

    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer, mediaFactory: MediaFactory, chatFactory: ChatFactory) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
        self.mediaFactory = mediaFactory
        self.chatFactory = chatFactory
    }
    
    func makeFactory() -> HomeFactory { Impl(container: self) }
    
    private final class Impl: HomeFactory {

        private let container: HomeDIContainer
        init(container: HomeDIContainer) { self.container = container }

        func makeHomeViewModel() -> HomeViewModel {
            HomeViewModel(activityUseCases: container.makeActivityUseCase())
        }

        func makeDetailViewModel(id: String) -> DetailViewModel {
            DetailViewModel(
                activityUseCases: container.makeActivityUseCase(),
                reviewLookupUseCase: container.makeReviewRatingLookUpUseCase(),
                orderUseCaes: container.makeCreateOrderUseCase(),
                chatService: container.commonDIContainer.makeDetailFeatureService().chatRoom,
                favoirteService: container.commonDIContainer.makeDetailFeatureService().favorite,
                paymentValidationUseCase: container.makePaymentValidationUseCase(),
                activityID: id
            )
        }

        func makePaymentViewModel() -> PaymentViewModel {
            PaymentViewModel(
                vaildationUseCase: container.makePaymentValidationUseCase()
            )
        }

        func makeSearchViewModel() -> SearchViewModel {
            SearchViewModel(
                activityUseCases: container.makeActivityUseCase()
            )
        }

        func makeBannerViewModel() -> BannerViewModel {
            BannerViewModel(bannerUseCase: container.makeBannerInfoUseCase())
        }

        func makeReviewViewModel(id: String) -> ReviewViewModel {
            ReviewViewModel(
                activityID: id,
                reviewUseCase: container.makeActivityRivewLookUpUseCase()
            )
        }
        
        func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel {
            container.mediaFactory.makeZoomableImageFullScreenViewModel()
        }

        func makeVideoPlayerViewModel() -> VideoPlayerViewModel {
            container.mediaFactory.makeVideoPlayerViewModel()
        }
        
        func makeChatRoomViewModel(roomID: String, opponentNick: String) -> ChatRoomViewModel {
            container.chatFactory.makeChatRoomViewModel(roomID: roomID, opponentNick: opponentNick)
        }
        
    }

}



// MARK: Maek Home UseCase
extension HomeDIContainer {
    
    
    // MARK: Make Activity Bundle
    private func makeActivityUseCase() -> ActivityUseCases {
        ActivityUseCases(
            activityNewList: makeNewActivityListUseCase(),
            activityList: makeActivityListUseCase(),
            activityDetail: makeActivityDetailUseCase(),
            activityKeepCommand: commonDIContainer.makeActivityKeepCommandUseCase(),
            activitySearch: makeActivitySearchUseCase()
        )
    }
    
    private func makeNewActivityListUseCase() -> NewActivityListUseCase {
        DefaultNewActivityListUseCase(repo: makeActivityRepository())
    }
    
    private func makeActivityListUseCase() -> ActivityListUseCase {
        DefaultActivityListUseCase(repo:  makeActivityRepository())
    }
    
    private func makeActivityDetailUseCase() -> ActivityDetailUseCase {
        DefaultActivityDetailUseCase(repo:  makeActivityRepository())
    }
    
    private func makeActivitySearchUseCase() -> ActivitySearchUseCase {
        DefaultActivitySearchUseCase(repo: makeActivityRepository())
    }
    
    
    // MARK: ReView
    private func makeReviewRatingLookUpUseCase() -> ReviewRatingLookUpUseCase {
        DefaultReviewRatingLookUpUseCase(repo: commonDIContainer.makeReviewRepository())
    }
    
    private func makeActivityRivewLookUpUseCase() -> ActivityReviewLookUpUseCase {
        DefaultActivityReviewLookUpUseCase(repo: commonDIContainer.makeReviewRepository())
    }

    
    // MARK: Chat
    private func makeCreateChatRoomUseCase() -> CreateChatRoomUseCase {
        DefaultCreateChatRoomUseCase(repo: commonDIContainer.makeChatRepository())
    }

 
    
    // MARK: Order
    private func makeCreateOrderUseCase() -> CreateOrderUseCase {
        
        DefaultCreateOrderUseCase(
            repo: commonDIContainer.makeOrderRepository()
        )
    }
    
    // MARK: Payment
    private func makePaymentValidationUseCase() -> PaymentValidationUseCase {
        DefaultPaymentValidationUseCase(repo: makePaymentRepository())
    }


    private func makeBannerInfoUseCase() -> BannerInfoUseCase {
        DefaultBannerInfoUseCase(repo: makeBannerInfoRepository())
    }
    
    
}


// MARK: Data
extension HomeDIContainer {
    
    /// 액티비티 목록 조회 등
    private func makeActivityRepository() -> DefaultActivityRepository {
        DefaultActivityRepository(networkService: networkService)
    }
    
    /// 결제
    private func makePaymentRepository() -> DefaultPaymentRepository {
        DefaultPaymentRepository(networkService: networkService)
    }
    
    /// 배너 관련
    private func makeBannerInfoRepository() -> DefaultBannerRepository {
        DefaultBannerRepository(networkService: networkService)
    }
}



// MARK: Make ViewModel
//extension HomeDIContainer {
//
//    func makeHomeViewModel() -> HomeViewModel {
//        HomeViewModel(activityUseCases: makeActivityUseCase())
//    }
//
//    func makeDetailViewModel(id: String) -> DetailViewModel {
//        DetailViewModel(
//            activityUseCases: makeActivityUseCase(),
//            reviewLookupUseCase: makeReviewRatingLookUpUseCase(),
//            orderUseCaes: makeCreateOrderUseCase(),
//            chatService: commonDIContainer.makeDetailFeatureService().chatRoom,
//            favoirteService: commonDIContainer.makeDetailFeatureService().favorite,
//            activityID: id
//        )
//    }
//
//    func makePaymentViewModel() -> PaymentViewModel {
//        PaymentViewModel(
//            vaildationUseCase: PaymentValidationUseCase()
//        )
//    }
//
//    func makeSearchViewModel() -> SearchViewModel {
//        SearchViewModel(
//            activityUseCases: makeActivityUseCase(),
//        )
//    }
//
//    // UIScreen.main.scale -> 삭제될 예정
//    // DI로 주입은 해주나, 나중에 onAppear 사점에서 추가적으로 주입해야 할 수도 있음
//    func makeBannerViewModel() -> BannerViewModel {
//        BannerViewModel(bannerUseCase: makeBannerInfoUseCase())
//
//    }
//
////    func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel {
////        ZoomableImageFullScreenViewModel(imageLoadUseCases: commonDIContainer.makeImageLoadUseCase())
////    }
////
////    func makeVideoPlayerViewModel() -> VideoPlayerViewModel {
////        VideoPlayerViewModel(videoLoader: videoLoader)
////    }
////
//    func makeReviewViewModel(id: String) -> ReviewViewModel {
//        ReviewViewModel(
//            activityID: id,
//            reviewUseCase: makeActivityRivewLookUpUseCase()
//        )
//    }
//
//}
