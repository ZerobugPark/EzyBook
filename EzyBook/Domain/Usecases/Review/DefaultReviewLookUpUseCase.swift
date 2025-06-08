//
//  DefaultReviewLookUpUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation

final class DefaultReviewLookUpUseCase {
    
    private let repo: ReviewRatingListRepository
    
    init(repo: ReviewRatingListRepository) {
        self.repo = repo
    }
    
    func execute(id: String) async throws -> ReviewRatingListEntity {
        
        let router = ReviewGetRequest.reviewRatingList(id: id)

        do {
            return try await repo.requestReviewRatingist(router)
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
    
}
