//
//  DefaultReviewRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation


final class DefaultReviewRepository: ReviewRatingListRepository, ReviewWriteRepository {


    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 리뷰 별정 조회
    func requestReviewRatingist(_ id: String) async throws -> ReviewRatingListEntity {
        
        let router = ReViewRequest.Get.reviewRatingList(id: id)
        
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
        
        let router = ReViewRequest.Post.writeReview(id: id, dto: dto)
        
        let data = try await networkService.fetchData(dto: UserReviewResponseDTO.self, router)
        return data.toEntity()
        
        
    }

    

}

