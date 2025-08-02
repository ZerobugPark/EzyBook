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
    
    func excute(title: String) async throws -> [PostSummaryEntity] {
        try await repo.reqeustSearchPost(title)
    }
}
