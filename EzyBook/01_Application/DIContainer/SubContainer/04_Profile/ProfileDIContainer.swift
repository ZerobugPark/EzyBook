//
//  ProfileDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import Foundation
import UIKit

final class ProfileDIContainer {
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    private let communityDIContainer: CommunityDIContainer
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer, communityDIContainer: CommunityDIContainer) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
        self.communityDIContainer = communityDIContainer
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
    
    func makeMyPostViewModel(postStatus: PostStatus) -> MyPostViewModel {
        MyPostViewModel(
            favoriteList: commonDIContainer.makeDetailFeatureService().favorite,
            postStatus: postStatus,
            deleteUseCase: communityDIContainer.makePostDeleteUseCase()
        )
    }
    
}
