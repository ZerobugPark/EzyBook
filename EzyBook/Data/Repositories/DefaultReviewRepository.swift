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
    func requestReviewRatingist(_ router: ReViewRequest.Get) async throws -> ReviewRatingListEntity {
        let data = try await networkService.fetchData(dto: ReViewRatingListResponseDTO.self, router)
        return data.toEntity()
    }
    
    /// 리뷰 작성
    func requestWriteReivew(_ router: ReViewRequest.Post) async throws -> UserReviewEntity {
        let data = try await networkService.fetchData(dto: UserReviewResponseDTO.self, router)
        return data.toEntity()
        
    }
    

}

