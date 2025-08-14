//
//  CommunityDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation

protocol CommunityFactory {
    func makeCommunityViewModel() -> CommunityViewModel
    func makeMyActivityListViewModel() -> MyActivityListViewModel
    func makePostViewModel(_ status: PostStatus) -> PostViewModel
    func makePostDetailViewModel(postID: String) -> PostDetailViewModel
    func makeReplyViewModle(data: CommentEntity, postID: String) -> ReplyViewModel
    func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel
    func makeVideoPlayerViewModel() -> VideoPlayerViewModel
}


final class CommunityDIContainer {
    
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    private let mediaFactory: MediaFactory
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer, mediaFactory: MediaFactory) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
        self.mediaFactory = mediaFactory
    }
    
    func makeFactory() -> CommunityFactory { Impl(container: self) }
    
    private final class Impl: CommunityFactory {
        
        private let container: CommunityDIContainer
        
        init(container: CommunityDIContainer) { self.container = container }
        
        func makeCommunityViewModel() -> CommunityViewModel {
            CommunityViewModel(
                communityUseCases: container.makeCommunityUseCases(),
                loactionService: container.commonDIContainer.makeDetailFeatureService().location
            )
        }
        
        func makeMyActivityListViewModel() -> MyActivityListViewModel {
            MyActivityListViewModel(
                orderListUseCase: container.makeOrderListUseCase(),
                userWrittenPostListUseCase: container.makeUserWrittenPostListUseCase()
            )
        }
        
        func makePostViewModel(_ status: PostStatus) -> PostViewModel {
            PostViewModel(
                uploadUseCase: container.makePostImageUploadUseCase(),
                writePostUseCase: container.makePostWirteUseCase(),
                postStatus: status,
                modifyPostUseCsae: container.makeModifyPostUseCase()
                
            )
        }
        
        func makePostDetailViewModel(postID: String) -> PostDetailViewModel {
            PostDetailViewModel(
                postDetailUseCase: container.makePostDetailUesCase(),
                postService: container.makePostFeatureService(),
                postLikeUseCase: container.commonDIContainer.makePostLikeUseCase(),
                postID: postID
            )
        }
        
        func makeReplyViewModle(data: CommentEntity, postID: String) -> ReplyViewModel {
            ReplyViewModel(
                commentData: data,
                postService: container.makePostFeatureService(),
                postID: postID
            )
        }
        
        func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel {
            container.mediaFactory.makeZoomableImageFullScreenViewModel()
        }

        func makeVideoPlayerViewModel() -> VideoPlayerViewModel {
            container.mediaFactory.makeVideoPlayerViewModel()
        }
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
    
    ///게시글 삭제
    func makePostDeleteUseCase() -> PostDeleteUseCase {
        DefaultPostDeleteUseCase(repo: makeCommunityRepository())
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
    private func makePostFeatureService() -> PostFeatureService {
        DefaultPostFeatureService(
            write: makePostWriteServiceProtocol(),
            delete: makePostDeleteServiceProtocol(),
            modify: makePostModifyServiceProtocol()
        )
    }
    
    /// Write
    private func makePostWriteServiceProtocol() -> PostWriteServiceProtocol {
        PostWriteService(write: makeWriteCommentUseCase())
    }
    
    private func makeWriteCommentUseCase() -> WriteCommentUseCase {
        DefaultWriteCommentUseCase(repo: makeCommentRepository())
    }
    
    /// Delete
    private func makePostDeleteServiceProtocol() -> PostDeleteServiceProtocol {
        PostDeleteService(delete: makeDeleteCommentUseCase())
    }
    
    private func makeDeleteCommentUseCase() -> DeleteCommentUseCase {
        DefaultDeleteCommentUseCase(repo: makeCommentRepository())
    }
    
    /// Modify
    private func makePostModifyServiceProtocol() -> PostModifyServiceProtocol {
        PostModifyService(modify: makeModifyCommnetUseCase())
    }
    
    private func makeModifyCommnetUseCase() -> ModifyCommnetUseCase {
        DefaultModifyCommnetUseCase(repo: makeCommentRepository())
    }
    
    private func makeModifyPostUseCase() -> PostModifyUseCase {
        DefaultPostModifyUseCase(repo: makeCommunityRepository())
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

//
//extension CommunityDIContainer {
//    
//    func makeCommunityViewModel() -> CommunityViewModel {
//        CommunityViewModel(
//            communityUseCases: makeCommunityUseCases(),
//            loactionService: commonDIContainer.makeDetailFeatureService().location
//        )
//    }
//    
//    func makeMyActivityListViewModel() -> MyActivityListViewModel {
//        MyActivityListViewModel(
//            orderListUseCase: makeOrderListUseCase(),
//            userWrittenPostListUseCase: makeUserWrittenPostListUseCase()
//        )
//    }
//    
//    func makePostViewModel(_ status: PostStatus) -> PostViewModel {
//        PostViewModel(
//            uploadUseCase: makePostImageUploadUseCase(),
//            writePostUseCase: makePostWirteUseCase(),
//            postStatus: status,
//            modifyPostUseCsae: makeModifyPostUseCase()
//            
//        )
//    }
//    
//    func makePostDetailViewModel(postID: String) -> PostDetailViewModel {
//        PostDetailViewModel(
//            postDetailUseCase: makePostDetailUesCase(),
//            postService: makePostFeatureService(),
//            postLikeUseCase: commonDIContainer.makePostLikeUseCase(),
//            postID: postID
//        )
//    }
//    
//    func makeReplyViewModle(data: CommentEntity, postID: String) -> ReplyViewModel {
//        ReplyViewModel(
//            commentData: data,
//            postService: makePostFeatureService(),
//            postID: postID
//        )
//    }
//}
