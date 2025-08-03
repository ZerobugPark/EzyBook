//
//  CommunityImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import Foundation


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


// MARK: 액티비티 게시글 작성 여부 렘 데이터 조회
final class DefaultWrittenActivityListUseCase: WrittenActivityListUseCase {
    
    private let repo: any WrittenActivityRepository
    
    init(repo: any WrittenActivityRepository) {
        self.repo = repo
    }
    
}
extension DefaultWrittenActivityListUseCase {
    
    func execute() -> [String] {
        repo.fetchActivityWrittenList()
    }
}

final class DefaultWriteActivityUseCase: WriteActivityUseCase {
    
    private let repo: any WrittenActivityRepository
    
    init(repo: any WrittenActivityRepository) {
        self.repo = repo
    }
    
}
extension DefaultWriteActivityUseCase {
    
    func execute(activityID: String)  {
        repo.save(activityID: activityID)
    }
}
