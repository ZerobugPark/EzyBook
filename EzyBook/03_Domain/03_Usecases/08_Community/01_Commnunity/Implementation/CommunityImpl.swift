//
//  CommunityImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import UIKit


final class DefaultPostSummaryPaginationUseCase: PostSummaryPaginationUseCase {
    
    private let repo: PostSummaryPaginationRepository
    
    init(repo: PostSummaryPaginationRepository) {
        self.repo = repo
    }
    
}

extension DefaultPostSummaryPaginationUseCase {
    
    func execute(query: ActivityPostLookUpQuery) async throws -> PostSummaryPaginationEntity {
        try await repo.requestActivityPost(query: query)
    }
}


final class DefaultPostSearchUseCase: PostSearchUseCase {
    private let repo: PostSearchRepository
    
    init(repo: PostSearchRepository) {
        self.repo = repo
    }
    
}

extension DefaultPostSearchUseCase {
    
    func execute(title: String) async throws -> [PostSummaryEntity] {
        try await repo.reqeustSearchPost(title)
    }
}


final class DefaultPostActivityUseCase: PostActivityUseCase {
    
    let repo: PostActivityRepository
    
    init(repo: PostActivityRepository) {
        self.repo = repo
    }
}

extension DefaultPostActivityUseCase {
    
    func execute(country: String, category: String, title: String, content: String, activity_id: String, latitude: Double, longitude: Double, files: [String]) async throws -> PostEntity {
        
        try await repo.requestWirtePost(country, category, title, content, activity_id: activity_id, latitude: latitude, longitude: longitude, files)
    }
}


final class DefaultUserWirttenPostListUseCase: UserWrittenPostListUseCase {
    let repo: WrittenPostListRepository
    
    init(repo: WrittenPostListRepository) {
        self.repo = repo
    }
    
}

extension DefaultUserWirttenPostListUseCase {
    func excute(userID: String) async throws -> [String] {
        try await repo.requestWrittenPostList(id: userID)
    }
}

final class DefaultPostDetailUseCase: PostDetailUseCase {

    let repo: PostDetailRepository
    
    init(repo: PostDetailRepository) {
        self.repo = repo
    }
}
extension DefaultPostDetailUseCase {
    
    func execute(postID: String) async throws -> PostEntity {
        try await repo.requestPostDetail(postID: postID)
    }
}

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




// MARK: 이미지 업로드
final class DefaultPostImageUploadUseCase: PostImageUploadUseCase {
    
    let repo: PostUploadRepository
    
    init(repo: PostUploadRepository) {
        self.repo = repo
    }
    
}


extension DefaultPostImageUploadUseCase {
    
    
    func execute(images: [UIImage]) async throws -> FileResponseEntity {
        try await repo.requesPostUploadImages(images)
    }
    
    func execute(videos: [Data]) async throws -> FileResponseEntity {
        try await repo.requesPostUploadVideos(videos)
    }
}


