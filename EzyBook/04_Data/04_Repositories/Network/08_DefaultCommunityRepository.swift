//
//  DefaultCommunityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import Foundation


final class DefaultCommunityRepository: PostSummaryPaginationRepository, PostSearchRepository, PostActivityRepository, WrittenPostListRepository, PostDetailRepository, PostDeleteRepository, PostModifyRepository {
    
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
    
    /// 포스트 작성
    func requestWritePost(_ country: String, _ category: String, _ title: String, _ content: String, activity_id: String, latitude: Double, longitude: Double, _ files: [String]) async throws -> PostEntity {
        
        let dto = ActivityPostRequestDTO(
            country: country,
            category: category,
            title: title,
            content: content,
            activityID: activity_id,
            latitude: latitude,
            longitude: longitude,
            files: files
        )
        
        let router = ActivityPostRequest.Post.writePost(body: dto)
        
        let data = try await networkService.fetchData(dto: PostResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    /// 작성된 포스트 리스트 (내가 작성한 리스트 X)
    func requestWrittenPostList(id: String) async throws -> [String] {
        var allPostIDs: [String] = []
        var nextCursor: String? = nil

        repeat {
            let dto = MyActivityQuery(country: nil, category: nil, limit: String(10), next: nextCursor)
            let router = ActivityPostRequest.Get.writtenPost(userID: id, dto: dto)
            let data = try await networkService.fetchData(dto: PostSummaryPaginationResponseDTO.self, router)

            allPostIDs.append(contentsOf: data.data.map { $0.activity?.id ?? "" })
            nextCursor = data.nextCursor
        } while (nextCursor ?? "0") != "0"

        return allPostIDs
    }
    
    /// 포스트 상세 조회
    func requestPostDetail(postID: String) async throws -> PostEntity {
        
        let router = ActivityPostRequest.Get.detailPost(postID: postID)
        let data = try await networkService.fetchData(dto: PostResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    /// 포스트 삭제
    func requestDeletePost(postID: String) async throws -> EmptyEntity {
        
        let router = ActivityPostRequest.Delete.deletePost(postID: postID)
        
        let data = try await networkService.fetchData(dto: EmptyDTO.self, router)
        
        return data.toEntity()
    }
    
    
    /// 포스트 수정
    func requestModifyPost(_ postID: String, _ title: String?, _ content: String?, _ files: [String]?) async throws -> PostEntity {
        
        let dto = ActivityPostModifyRequestDTO(
            title: title,
            content: content,
            files: files
        )
        
        
        let router = ActivityPostRequest.Put.modifyPost(postID: postID, body: dto)
        
        let data = try await networkService.fetchData(dto: PostResponseDTO.self, router)
        
        return data.toEntity()
        
    }
 
}


