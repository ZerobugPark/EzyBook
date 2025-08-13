//
//  ProfileDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import Foundation
import UIKit

protocol ProfileFactory {
    func makeProfileVM() -> ProfileViewModel
    func makeSupplementVM() -> ProfileSupplementaryViewModel
    func makeOrderListVM(orderList: [OrderEntity]) -> OrderListViewModel
}


final class ProfileDIContainer {
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    private let communityDIContainer: CommunityDIContainer
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer, communityDIContainer: CommunityDIContainer) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
        self.communityDIContainer = communityDIContainer
    }
    
    // Expose a factory that knows how to build view models, while keeping wiring here in DI
    func makeFactory() -> ProfileFactory { Impl(container: self) }

    // Private implementation of ProfileFactory
    private final class Impl: ProfileFactory {
        private let container: ProfileDIContainer
        init(container: ProfileDIContainer) { self.container = container }

        func makeProfileVM() -> ProfileViewModel {
            container.makeProfileViewModel()
        }

        func makeSupplementVM() -> ProfileSupplementaryViewModel {
            container.makeProfileSupplementaryViewModel()
        }

        func makeOrderListVM(orderList: [OrderEntity]) -> OrderListViewModel {
            container.makeOrderListViewModel(orderList: orderList)
        }
    }


    
}

// MARK: Maek Profile UseCase
extension ProfileDIContainer {
    
    
    // MARK: Make Profile Bundle
    private func makeProfileUseCases() -> ProfileUseCases {
        ProfileUseCases(
            profileLookUp: makeProfileLookUpUseCase(),
            profileSearchUser: commonDIContainer.makeProfileSearchUseCase(),
            profileUploadImage: makeProfileUpLoadFileUseCase(),
            profileModify: makeProfileModifyUseCase()
        )
    }
    
    private func makeProfileLookUpUseCase() -> ProfileLookUpUseCase {
        DefaultProfileLookUpUseCase(repo: commonDIContainer.makeProfileRepository())
    }
    

    
    private func makeProfileUpLoadFileUseCase() -> ProfileUploadImageUseCase {
        DefaultProfileUploadImageUseCase(repo: commonDIContainer.makeUploadRepository())
    }
    
    private func makeProfileModifyUseCase() -> ProfileModifyUseCase {
        DefaultProfileModifyUseCase(repo: commonDIContainer.makeProfileRepository())
    }
    
 
    
    
    // MARK: Make Review Bundle
    private func makeReviewUseCases() -> ReviewUseCases {
        ReviewUseCases(
            imageUpload: makeReviewImageUploadUseCase(),
            reviewWrite: makeReviewWirteUseCase(),
            reviewModify: makeReviewModifyUseCase(),
            reviewDelete: makeReviewDeleteUseCase(),
            reviewDetail: makeReviewDetailUseCase()
        )
    }
    
    private func makeReviewImageUploadUseCase() -> ReviewImageUpload {
        DefaultReviewImageUpload(repo: commonDIContainer.makeUploadRepository())
    }
    
    // MARK: Reivew CRUD
    private func makeReviewWirteUseCase() -> ReviewWriteUseCase {
        DefaultReviewWriteUseCase(repo: commonDIContainer.makeReviewRepository())
    }
    
    private func makeReviewModifyUseCase() -> ReviewModifyUseCase {
        DefaultReviewModifyUseCase(repo: commonDIContainer.makeReviewRepository())
    }
    
    private func makeReviewDeleteUseCase() -> ReviewDeleteUseCase {
        DefaultReviewDeleteUseCase(repo: commonDIContainer.makeReviewRepository())
    }

    
    // MARK:  Review Detail 조회
    private func makeReviewDetailUseCase() -> ReviewDetailUseCase {
        DefaultReviewDetailUseCase(repo: commonDIContainer.makeReviewRepository())
    }



    
    
    // MARK: Make Order List
    private func makeOrderListUseCase() -> OrderListLookUpUseCase {
        DefaultOrderListLookupUseCase(
            repo: commonDIContainer.makeOrderRepository()
        )
        
    }

    
}


// MARK: Data
extension ProfileDIContainer {

    
}


// MARK: Make ViewModel
extension ProfileDIContainer {
    
    func makeProfileViewModel() -> ProfileViewModel {
        
        ProfileViewModel(
            profileUseCases: makeProfileUseCases()
        )
    }
    
    
    func makeOrderListViewModel(orderList: [OrderEntity]) -> OrderListViewModel {
        
        OrderListViewModel(
            orderList: orderList
        )
    }
    
    func makeProfileSupplementaryViewModel() -> ProfileSupplementaryViewModel {
        ProfileSupplementaryViewModel(
            orderListUseCase: makeOrderListUseCase()
        )
    }
    
    func makeWriteReviewViewModel(id: String, code: String) -> ReviewWriteViewModel {
        ReviewWriteViewModel(
            reviewUseCases: makeReviewUseCases(),
            activityId: id,
            orderCode: code
        )
    }
    
    func makeModifyReviewViewModel(_ data: UserReviewDetailList) -> ReviewModifyViewModel {
        ReviewModifyViewModel(
            reviewUseCases: makeReviewUseCases(),
            reviewData: data
        )
    }
    
    
    func makeReviewViewModel(list: [OrderEntity]) -> ReviewDetailViewModel {
        
        let filterList = list.filter { $0.review != nil }
        
        return ReviewDetailViewModel(
            reviewUseCases: makeReviewUseCases(),
            orderList: filterList
        )
    }
    
    func makeProfileModifyViewModel() -> ProfileModifyViewModel {
        ProfileModifyViewModel(
            useCase: makeProfileModifyUseCase()
        )
    }
    
    func makeActiviyLikeViewModel() -> ActiviyLikeViewModel {
        ActiviyLikeViewModel(favoriteList: commonDIContainer.makeDetailFeatureService().favorite)
    }
    
    func makeMyPostViewModel(postCategory: ProfilePostCategory) -> MyPostViewModel {
        MyPostViewModel(
            favoriteList: commonDIContainer.makeDetailFeatureService().favorite,
            postCategory: postCategory,
            deleteUseCase: communityDIContainer.makePostDeleteUseCase()
        )
    }
    
}
