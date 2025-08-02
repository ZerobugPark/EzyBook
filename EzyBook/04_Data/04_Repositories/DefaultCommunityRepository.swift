//
//  DefaultCommunityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import Foundation


final class DefaultCommunityRepository: PostSummaryPaginationRepository, PostSearchRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    
    /// 액티비티 게시글 조회
    func requestActivityPost(query: ActivityPostLookUpQuery)  async throws -> PostSummaryPaginationEntity {
        

        let router = ActivityPostRequest.Get.postLookup(query: query)
        
        let data = try await networkService.fetchData(dto: PostSummaryPaginationResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    /// 특정 포스트 조회
    func reqeustSearchPost(_ title: String) async throws -> [PostSummaryEntity] {
        
        let router = ActivityPostRequest.Get.postSearch(query: title)
        
        let data = try await networkService.fetchData(dto: PostSummaryListResponseDTO.self, router)
        
        return data.toEntity()
        
    }
}
