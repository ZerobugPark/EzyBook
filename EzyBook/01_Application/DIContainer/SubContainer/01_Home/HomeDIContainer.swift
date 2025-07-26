//
//  HomeDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import Foundation
import UIKit


final class HomeDIContainer {
    
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    private let videoLoader: VideoLoaderDelegate
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer, videoLoader: VideoLoaderDelegate) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
        self.videoLoader = videoLoader
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
    private func makeReviewLookUpUseCase() -> ReviewLookUpUseCase {
        DefaultReviewLookUpUseCase(repo: commonDIContainer.makeReviewRepository())
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
    private func PaymentValidationUseCase() -> PaymentValidationUseCase {
        DefaultPaymentValidationUseCase(repo: makePaymentRepository())
    }


    private func makeBannerInfoUseCase() -> BannerInfoUseCase {
        DefaultBannerInfoUseCase(repo: makeBannerInfoRepository())
    }
    
    
}


// MARK: Data
extension HomeDIContainer {
    
    private func makeActivityRepository() -> DefaultActivityRepository {
        DefaultActivityRepository(networkService: networkService)
    }
    
    
    private func makePaymentRepository() -> DefaultPaymentRepository {
        DefaultPaymentRepository(networkService: networkService)
    }
    
    private func makeBannerInfoRepository() -> DefaultBannerRepository {
        DefaultBannerRepository(networkService: networkService)
    }
    
  
}



// MARK: Make ViewModel
extension HomeDIContainer {
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            activityUseCases: makeActivityUseCase(),
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase(),
            scale: UIScreen.main.scale
        )
    }
    
    func makeDetailViewModel() -> DetailViewModel {
        DetailViewModel(
            activityUseCases: makeActivityUseCase(),
            reviewLookupUseCase: makeReviewLookUpUseCase(),
            orderUseCaes: makeCreateOrderUseCase(),
            createChatRoomUseCase: makeCreateChatRoomUseCase(),
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase()
        )
    }
    
    func makePaymentViewModel() -> PaymentViewModel {
        PaymentViewModel(
            vaildationUseCase: PaymentValidationUseCase()
        )
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            activityUseCases: makeActivityUseCase(),
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase()
        )
    }
    
    func makeBannerViewModel() -> BannerViewModel {
        BannerViewModel(
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase(),
            bannerUseCase: makeBannerInfoUseCase()
        )
    }

    func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel {
        ZoomableImageFullScreenViewModel(imageLoadUseCases: commonDIContainer.makeImageLoadUseCase())
    }
    
    func makeVideoPlayerViewModel() -> VideoPlayerViewModel {
        VideoPlayerViewModel(videoLoader: videoLoader)
    }
    
}
