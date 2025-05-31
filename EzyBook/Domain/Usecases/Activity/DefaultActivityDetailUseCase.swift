//
//  DefaultActivityDetailUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/27/25.
//

import Foundation

final class DefaultActivityDetailUseCase {
    
    private let repo: ActivityDetailRepository
    
    init(repo: ActivityDetailRepository) {
        self.repo = repo
    }
    
}

extension DefaultActivityDetailUseCase {
    
    func execute(id: String) async throws -> ActivityDetailEntity {
        let requestDto = ActivityDetailRequestDTO(activityId: id)
        
        let router = ActivityGetRequest.activityDetail(param: requestDto)
        
        do {
            let data = try await repo.requestActivityDetail(router)
            return data
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
    
}
