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
    
    // MARK: Make Order List
    private func makeOrderListUseCase() -> OrderListLookUpUseCase {
        DefaultOrderListLookupUseCase(
            repo: commonDIContainer.makeOrderRepository()
        )
    }
    
    // MARK: Realm
    private func makeWrittenActivityListUseCase() -> WrittenActivityListUseCase {
        DefaultWrittenActivityListUseCase(repo: makeWrittenActivityRepository())
    }
    
    private func makeWriteActivityUseCase() -> WriteActivityUseCase {
        DefaultWriteActivityUseCase(repo: makeWrittenActivityRepository())
    }

}


// MARK: Data
extension CommunityDIContainer {
    
    private func makeCommunityRepository() -> DefaultCommunityRepository {
        DefaultCommunityRepository(networkService: networkService)
    }

    private func makeWrittenActivityRepository() -> any WrittenActivityRepository {
        DefaultWrittenActivityRepository()
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
            writtenActivityUseCase: makeWrittenActivityListUseCase()
        )
    }
    
    func makePostViewModel() -> PostViewModel {
        PostViewModel(
            writeActivityUseCase: makeWriteActivityUseCase()
        )
    }
}
