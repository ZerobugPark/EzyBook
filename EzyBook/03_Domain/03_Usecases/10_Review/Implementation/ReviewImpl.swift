//
//  ReviewImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import SwiftUI


// MARK: 리뷰 이미지 업로드
final class DefaultReviewImageUpload: ReviewImageUpload {
    
    private let repo: ReviewImageUploadRepository
    
    init(repo: ReviewImageUploadRepository) {
        self.repo = repo
    }
    
}

extension DefaultReviewImageUpload {
    func execute(id: String, images: [UIImage]) async throws -> ReviewImageEntity {
        try await repo.requestReviewUploadImage(id, images)
    }
    
}


// MARK: 리뷰 작성
final class DefaultReViewWriteUseCase: ReViewWriteUseCase {
    
    private let repo: ReviewWriteRepository
    
    init(repo: ReviewWriteRepository) {
        self.repo = repo
    }
    
}

extension DefaultReViewWriteUseCase {
    
    func execute(
        id: String, content: String, rating: Int, reviewImageUrls: [String]?, orderCode: String) async throws -> UserReviewEntity {
        
        try await repo.requestWriteReivew(id, content, rating, reviewImageUrls, orderCode)
      
    }
    
}



// MARK: 리뷰 평점 조회
final class DefaultReviewRatingLookUpUseCase: ReviewRatingLookUpUseCase {
    
    private let repo: ReviewRatingListRepository
    
    init(repo: ReviewRatingListRepository) {
        self.repo = repo
    }

}

extension DefaultReviewRatingLookUpUseCase {
    func execute(id: String) async throws -> ReviewRatingListEntity {
        try await repo.requestReviewRatingist(id)
    }
}


// MARK: 리뷰 상세 조회
final class DefaultReviewDetailUseCase: ReviewDetailUseCase {
    private let repo: ReviewDetailRepository
    
    init(repo: ReviewDetailRepository) {
        self.repo = repo
    }
    
}
extension DefaultReviewDetailUseCase  {
    
    func execute(activityID: String, reviewID: String) async throws -> UserReviewEntity {
        try await repo.reqeustReviewDetailList(activityID, reviewID)
    }
    
}

// MARK: 액티비티 리뷰 목록 조회
final class DefaultActivityReviewLookUpUseCase: ActivityReviewLookUpUseCase {
    
    private let repo: ActivityReviewListRepository
    
    init(repo: ActivityReviewListRepository) {
        self.repo = repo
    }
    
}

extension DefaultActivityReviewLookUpUseCase {
    
    func execute(activityID: String) async throws -> ReviewListEntity {
        try await repo.requestActivityReviewList(activityID)
    }
}

