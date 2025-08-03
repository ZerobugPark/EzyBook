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
    
    // MARK: Make Order List
    private func makeOrderListUseCase() -> OrderListLookUpUseCase {
        DefaultOrderListLookupUseCase(
            repo: commonDIContainer.makeOrderRepository()
        )
    }
    
    // MARK: Realm
    private func makeWrittenActivityRealmListUseCase() -> WrittenActivityRealmListUseCase {
        DefaultWrittenActivityRealmListUseCase(repo: makeWrittenActivityRepository())
    }
    
    private func makeWriteActivityRealmUseCase() -> WriteActivityRealmUseCase {
        DefaultWriteActivityRealmUseCase(repo: makeWrittenActivityRepository())
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

    private func makeWrittenActivityRepository() -> any WrittenActivityRealmRepository {
        DefaultWrittenActivityRealmRepository()
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
            writtenActivityUseCase: makeWrittenActivityRealmListUseCase()
        )
    }
    
    func makePostViewModel() -> PostViewModel {
        PostViewModel(
            writeActivityRealmUseCase: makeWriteActivityRealmUseCase(),
            uploadUseCase: makePostImageUploadUseCase(),
            writePostUseCase: makePostWirteUseCase()
            
        )
    }
}
