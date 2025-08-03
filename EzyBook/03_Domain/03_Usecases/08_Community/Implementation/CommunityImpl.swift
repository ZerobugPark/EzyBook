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


// MARK: 액티비티 게시글 작성 여부 렘 데이터 조회
final class DefaultWrittenActivityRealmListUseCase: WrittenActivityRealmListUseCase {
    
    private let repo: any WrittenActivityRealmRepository
    
    init(repo: any WrittenActivityRealmRepository) {
        self.repo = repo
    }
    
}
extension DefaultWrittenActivityRealmListUseCase {
    
    func execute() -> [String] {
        repo.fetchActivityWrittenList()
    }
}

final class DefaultWriteActivityRealmUseCase: WriteActivityRealmUseCase {
    
    private let repo: any WrittenActivityRealmRepository
    
    init(repo: any WrittenActivityRealmRepository) {
        self.repo = repo
    }
    
}
extension DefaultWriteActivityRealmUseCase {
    
    func execute(activityID: String)  {
        repo.save(activityID: activityID)
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
