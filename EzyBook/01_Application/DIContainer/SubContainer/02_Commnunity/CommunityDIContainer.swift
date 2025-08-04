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
    
    private func makePostDetailUesCase() -> PostDetailUseCase {
        DefaultPostDetailUseCase(repo: makeCommunityRepository())
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

    
    // MARK: Comment
    private func makeCommentUseCases() -> CommentUseCases {
        CommentUseCases(
            write: makeWriteCommentUseCase(),
            delete: makeDeleteCommentUseCase()
        )
    }

    private func makeWriteCommentUseCase() -> WriteCommentUseCase {
        DefaultWriteCommentUseCase(repo: makeCommentRepository())
    }
    
    private func makeDeleteCommentUseCase() -> DeleteCommentUseCase {
        DefaultDeleteCommentUseCase(repo: makeCommentRepository())
    }

}


// MARK: Data
extension CommunityDIContainer {
    
    private func makeCommunityRepository() -> DefaultCommunityRepository {
        DefaultCommunityRepository(networkService: networkService)
    }
    
    private func makeCommentRepository() -> DefaultCommentRepository {
        DefaultCommentRepository(networkService: networkService)
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
    
    func makePostDetailViewModel(postID: String) -> PostDetailViewModel {
        PostDetailViewModel(
            postDetailUseCase: makePostDetailUesCase(),
            commentUseCases: makeCommentUseCases(),
            postID: postID
        )
    }
}
