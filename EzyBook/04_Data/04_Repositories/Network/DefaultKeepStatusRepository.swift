//
//  DefaultKeepStatusRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import Foundation


final class DefaultKeepStatusRepository: ActivityKeepCommandRepository,  ActivityKeepListRepository, PostLikeRepository, PostLikeListRepository, MyPostListRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 킵 요청
    func requestToggleKeep(_ id: String, _ stauts: Bool) async throws -> ActivityKeepEntity {
        let dto = ActivityKeepRequestDTO(status: stauts)
        let router = ActivityRequest.Post.activityKeep(id: id, param: dto)
        
        let data = try await networkService.fetchData(dto: ActivityKeepResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    
    func requestActivityLikeList(next: String?, limit: String) async throws -> ActivitySummaryListEntity {
        
        let dto = ActivitySummaryListRequestDTO(country: nil, category: nil, limit: limit, next: next)
        let router = ActivityRequest.Get.keptActivities(param: dto)
        
        
        let data = try await networkService.fetchData(dto: ActivitySummaryListResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    
    
    func requestPostLike(_ postID: String, _ status: Bool) async throws -> PostKeepEntity {
        
        let dto = ActivityPostLikeRequestDTO(likeStatus: status)
        
        let router = ActivityPostRequest.Post.postKeep(postID: postID, body: dto)
        let data = try await networkService.fetchData(dto: PostKeepResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    func requestPostLikeList(_ next: String?, _ limit: String) async throws -> PostSummaryPaginationEntity {
        
        let dto = MyActivityQuery(country: nil, category: nil, limit: limit, next: next)
        
        let router = ActivityPostRequest.Get.likedPosts(dto: dto)
        
        let data = try await networkService.fetchData(dto: PostSummaryPaginationResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    func reqeustMyPostList(_ next: String?, _ limit: String, _ userID: String)  async throws -> PostSummaryPaginationEntity {
        
        
        let dto = MyActivityQuery(country: nil, category: nil, limit: limit, next: next)
        
        let router = ActivityPostRequest.Get.writtenPost(userID: userID, dto: dto)
        
        let data = try await networkService.fetchData(dto: PostSummaryPaginationResponseDTO.self, router)
        
        return data.toEntity()
        
    }

}

