//
//  CommunityDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation

final class CommunityDIContainer {
    
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
    }
    
    
}


// MARK: Maek Community UseCase
extension CommunityDIContainer {
    
    
    private func makeCommunityUseCases() -> CommunityUseCases {
        CommunityUseCases(
            postSummary: makePostSummaryPaginationUseCase(),
            postSearch: makePostSearchUseCase()
        )
    }
    
    private func makePostSummaryPaginationUseCase() -> PostSummaryPaginationUseCase {
        DefaultPostSummaryPaginationUseCase(repo: makeCommunityRepository())
    }
    
    private func makePostSearchUseCase() -> PostSearchUseCase {
        DefaultPostSearchUseCase(repo: makeCommunityRepository())
    }
    
    
    private func makePostWirteUseCase() -> PostActivityUseCase {
        DefaultPostActivityUseCase(repo: makeCommunityRepository())
    }
    
    private func makeUserWrittenPostListUseCase() -> UserWrittenPostListUseCase {
        DefaultUserWirttenPostListUseCase(repo: makeCommunityRepository())
    }
    
    // MARK: Make Order List
    private func makeOrderListUseCase() -> OrderListLookUpUseCase {
        DefaultOrderListLookupUseCase(
            repo: commonDIContainer.makeOrderRepository()
        )
    }
    
    // MARK: 이미지 업로드
    private func makePostImageUploadUseCase() -> PostImageUploadUseCase {
        DefaultPostImageUploadUseCase(repo: commonDIContainer.makeUploadRepository())
    }


}


// MARK: Data
extension CommunityDIContainer {
    
    private func makeCommunityRepository() -> DefaultCommunityRepository {
        DefaultCommunityRepository(networkService: networkService)
    }

}


extension CommunityDIContainer {
    
    func makeCommunityViewModel() -> CommunityViewModel {
        CommunityViewModel(
            communityUseCases: makeCommunityUseCases(),
            loactionService: commonDIContainer.makeDetailFeatureService().location
        )
    }
    
    func makeMyActivityListViewModel() -> MyActivityListViewModel {
        MyActivityListViewModel(
            orderListUseCase: makeOrderListUseCase(),
            userWrittenPostListUseCase: makeUserWrittenPostListUseCase()
        )
    }
    
    func makePostViewModel() -> PostViewModel {
        PostViewModel(
            uploadUseCase: makePostImageUploadUseCase(),
            writePostUseCase: makePostWirteUseCase()
            
        )
    }
}
