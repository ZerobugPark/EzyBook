//
//  DefaultUploadReviewImages.swift
//  EzyBook
//
//  Created by youngkyun park on 6/24/25.
//

import UIKit

struct DefaultUploadReviewImages {
    
    private let repo: ReviewImageUploadRepository
    
    init(repo: ReviewImageUploadRepository) {
        self.repo = repo
    }

    func execute(_ id: String, _ images: [UIImage]) async throws -> ReviewImageEntity {
        
        let router = ReViewRequest.Multipart.reviewFiles(id: id, image: images)
        do {
            
            let image = try await repo.requestReviewUploadImage(router)
            return image

        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
    
    
    
}
