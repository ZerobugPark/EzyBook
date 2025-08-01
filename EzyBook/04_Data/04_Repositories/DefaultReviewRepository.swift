//
//  DefaultReviewRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation


final class DefaultReviewRepository: ReviewRatingListRepository, ReviewWriteRepository, ReviewDetailRepository, ActivityReviewListRepository {


    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 리뷰 별정 조회
    func requestReviewRatingist(_ id: String) async throws -> ReviewRatingListEntity {
        
        let router = ReviewRequest.Get.reviewRatingList(id: id)
        
        let data = try await networkService.fetchData(dto: ReViewRatingListResponseDTO.self, router)
        
        return data.toEntity()
    }

    
    /// 리뷰 작성
    func requestWriteReivew(_ id: String, _ content: String, _ rating: Int, _ reviewImageUrls: [String]?, _ orderCode: String) async throws -> UserReviewEntity {
        
        
        let dto = ReviewWriteRequestDTO(
            content: content,
            rating: rating,
            reviewImageUrls: reviewImageUrls,
            orderCode: orderCode
        )
        
        let router = ReviewRequest.Post.writeReview(id: id, dto: dto)
        
        let data = try await networkService.fetchData(dto: UserReviewResponseDTO.self, router)
        return data.toEntity()
        
        
    }
    
    // 리뷰 상세 조회
    func reqeustReviewDetailList(_ activityID: String, _ reviewID: String) async throws -> UserReviewEntity {
        
        let router = ReviewRequest.Get.reviewDetail(id: activityID, reviewID: reviewID)
        
        let data = try await networkService.fetchData(dto: UserReviewResponseDTO.self, router)
        
        return data.toEntity()
        
    }

    
    // 리뷰 목록 조회
    func requestActivityReviewList(_ activityID: String) async throws -> ReviewListEntity {
        
        let router = ReviewRequest.Get.reviewList(id: activityID)
        
        let data = try await networkService.fetchData(dto: ReviewListResponseDTO.self, router)
        
        return data.toEntity()
    }

}

