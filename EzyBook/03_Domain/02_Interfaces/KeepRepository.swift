//
//  KeepRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/10/25.
//

import Foundation

/// 액티비티 좋아요
protocol ActivityKeepCommandRepository {
    func requestToggleKeep(_ id: String, _ stauts: Bool) async throws -> ActivityKeepEntity
}

/// 액티비티 좋아요 리스트
protocol ActivityKeepListRepository {
    func requestActivityLikeList(next: String?, limit: String) async throws -> ActivitySummaryListEntity
}


/// 게시글 좋아요
protocol PostLikeRepository {
    func requestPostLike(_ postID: String, _ status: Bool) async throws -> PostKeepEntity
}

/// 게시글 좋아요 목록
protocol PostLikeListRepository {
    func requestPostLikeList(_ next: String?, _ limit: String) async throws -> PostSummaryPaginationEntity
}


/// 내가 작성한 게시글 목록
protocol MyPostListRepository {
    func reqeustMyPostList(_ next: String?, _ limit: String, _ userID: String)  async throws -> PostSummaryPaginationEntity
}
