//
//  DefaultReViewWriteUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/24/25.
//

import Foundation

struct DefaultReViewWriteUseCase {
    
    private let repo: ReviewWriteRepository
    
    init(repo: ReviewWriteRepository) {
        self.repo = repo
    }

    func execute(_ id: String, _ dto: ReviewWriteRequestDTO) async throws -> UserReviewEntity {
        
        let router = ReViewRequest.Post.writeReview(id: id, dto: dto)
        do {
            
            let data = try await repo.requestWriteReivew(router)
            return data

        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
    
    
    
}

