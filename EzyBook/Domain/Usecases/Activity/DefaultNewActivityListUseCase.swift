//
//  DefaultNewActivityListUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation
import Combine

final class DefaultNewActivityListUseCase {
    
    private let repo: ActivityQueryRepository
    
    init(repo: ActivityQueryRepository) {
        self.repo = repo
    }
    
    
}


extension DefaultNewActivityListUseCase {

    func execute(country: String?, category: String?) async throws -> [ActivitySummaryEntity] {
        let requestDto = ActivityNewSummaryListRequestDTO(country: country, category: category)
        let router = ActivityRequest.newActivities(param: requestDto)

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
