//
//  KeepCommandUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 8/10/25.
//

import Foundation

/// 액티비티 좋아요
final class DefaultActivityKeepCommandUseCase: ActivityKeepCommandUseCase {
    
    private let repo: ActivityKeepCommandRepository
    
    init(repo: ActivityKeepCommandRepository) {
        self.repo = repo
    }
    

}

extension DefaultActivityKeepCommandUseCase {
    func execute(id: String, stauts: Bool) async throws -> ActivityKeepEntity {
        try await repo.requestToggleKeep(id, stauts)
    }
}


/// 액티비티 좋아요 리스트
final class DefaultActivityKeepListUseCase: ActivityKeepListUseCase {
    
    private let repo: ActivityKeepListRepository
    
    init(repo: ActivityKeepListRepository) {
        self.repo = repo
    }
    

}

extension DefaultActivityKeepListUseCase {
    func execute(next: String?, limit: String) async throws ->  ActivitySummaryListEntity {
        try await repo.requestActivityLikeList(next: next, limit: limit)
    }
}


/// 게시글 좋아요
final class DefaultPostLikeUseCase: PostLikeUseCase {
    
    let repo: PostLikeRepository
    
    init(repo: PostLikeRepository) {
        self.repo = repo
    }
}

extension DefaultPostLikeUseCase {
    
    func execute(postID: String, status: Bool) async throws -> PostKeepEntity {
        try await repo.requestPostLike(postID, status)
    }
}

/// 게시글 좋아요 리스트
final class DefaultPostLikeListUseCase: PostLikeListUseCase {
    
    let repo: PostLikeListRepository
    
    init(repo: PostLikeListRepository) {
        self.repo = repo
    }
}

extension DefaultPostLikeListUseCase {
    
    func execute(next: String?, limit: String) async throws -> PostSummaryPaginationEntity {
        try await repo.requestPostLikeList(next, limit)
    }
}

/// 내 게시글  리스트
final class DefaultMyPostUseCase: MyPostUseCase {
    
    let repo: MyPostListRepository
    
    init(repo: MyPostListRepository) {
        self.repo = repo
    }
}

extension DefaultMyPostUseCase {
    
    func execute(next: String?, limit: String, userID: String) async throws -> PostSummaryPaginationEntity {
        try await repo.reqeustMyPostList(next, limit, userID)
    }
}
