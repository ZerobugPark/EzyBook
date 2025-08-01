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
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
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
            reviewWrite: makeReviewWirteUseCase()
        )
    }
    
    private func makeReviewImageUploadUseCase() -> ReviewImageUpload {
        DefaultReviewImageUpload(repo: commonDIContainer.makeUploadRepository())
    }
    private func makeReviewWirteUseCase() -> ReViewWriteUseCase {
        DefaultReViewWriteUseCase(repo: commonDIContainer.makeReviewRepository())
    }

    
    
    // MARK: Make Order List
    private func makeOrderListUseCase() -> OrderListLookUpUseCase {
        DefaultOrderListLookupUseCase(
            repo: commonDIContainer.makeOrderRepository()
        )
        
    }
    
    // MARK:  Review Detail 조회
    private func makeReviewDetailUseCase() -> ReviewDetailUseCase {
        DefaultReviewDetailUseCase(repo: commonDIContainer.makeReviewRepository())
    }



    
}


// MARK: Data
extension ProfileDIContainer {

    
}



// MARK: Make ViewModel
extension ProfileDIContainer {
    
    func makeProfileViewModel() -> ProfileViewModel {
        
        ProfileViewModel(
            profileUseCases: makeProfileUseCases(),
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase(),
            scale: UIScreen.main.scale
        )
    }
    
    
    func makeOrderListViewModel(orderList: [OrderEntity]) -> OrderListViewModel {
        
        OrderListViewModel(
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase(),
            orderList: orderList
        )
    }
    
    func makeProfileSupplementaryViewModel() -> ProfileSupplementaryViewModel {
        ProfileSupplementaryViewModel(
            orderListUseCase: makeOrderListUseCase()
        )
    }
    
    func makeWriteReviewViewModel(id: String, code: String) -> WriteReviewViewModel {
        WriteReviewViewModel(
            reviewUseCases: makeReviewUseCases(),
            activityId: id,
            orderCode: code
        )
    }
    
    func makeReviewViewModel(list: [OrderEntity]) -> ReviewDetailViewModel {
        
        let filterList = list.filter { $0.review != nil }
        
        return ReviewDetailViewModel(
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase(),
            reviewDetailUseCase: makeReviewDetailUseCase(),
            orderList: filterList,
            scale: UIScreen.main.scale
        )
    }
    
    func makeProfileModifyViewModel() -> ProfileModifyViewModel {
        ProfileModifyViewModel(
            useCase: makeProfileModifyUseCase()
        )
    }
    
}
