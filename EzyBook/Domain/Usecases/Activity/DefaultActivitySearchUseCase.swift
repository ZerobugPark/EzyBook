//
//  DefaultActivitySearchUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

final class DefaultActivitySearchUseCase {

    private let repo: ActivityQueryRepository
    
    init(repo: ActivityQueryRepository) {
        self.repo = repo
    }
    
    
    func execute(title: String) async throws -> [ActivitySummaryEntity]  {
    
        let requestDto = ActivitySearchListRequestDTO(title: title)
        
        let router = ActivityGetRequest.serachActiviy(param: requestDto)
        
        do {
            return try await repo.requestActivityNewList(router)
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
}

