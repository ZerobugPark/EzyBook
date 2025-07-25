//
//  ActivityImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation


// MARK: 신규 액티비티 조회
final class DefaultNewActivityListUseCase: NewActivityListUseCase {
    
    private let repo: ActivityNewListRepository
    
    init(repo: ActivityNewListRepository) {
        self.repo = repo
    }
}

extension DefaultNewActivityListUseCase {
    func execute(country: String?, category: String?) async throws -> [ActivitySummaryEntity] {
        try await repo.requestActivityNewList(country, category)
    }
}


// MARK: 액티비티 목록
/// 필터 조건에 따른 액티비티 목록 조회
final class DefaultActivityListUseCase: ActivityListUseCase {
    
    private let repo: ActivityListRepository
    
    init(repo: ActivityListRepository) {
        self.repo = repo
    }
    
}

extension DefaultActivityListUseCase {
    func execute(country: String?, category: String?, limit: String, next: String?) async throws -> ActivitySummaryListEntity {
        
        try await repo.requestActivityList(country, category, limit, next)
    }
}


// MARK: 액티비티 상세 조회

final class DefaultActivityDetailUseCase: ActivityDetailUseCase {
    
    private let repo: ActivityDetailRepository
    
    init(repo: ActivityDetailRepository) {
        self.repo = repo
    }
    
}

extension DefaultActivityDetailUseCase {
    
    func execute(id: String) async throws -> ActivityDetailEntity {
        try await repo.requestActivityDetail(id)
    }
    
}



// MARK: 액티비티 검색

final class DefaultActivitySearchUseCase: ActivitySearchUseCase {

    private let repo: ActivitySearchRepository
    
    init(repo: ActivitySearchRepository) {
        self.repo = repo
    }
    

}

extension DefaultActivitySearchUseCase  {
    
    func execute(title: String) async throws -> [ActivitySummaryEntity]  {
        try await repo.requestActivitySearch(title)
      
    }
}

