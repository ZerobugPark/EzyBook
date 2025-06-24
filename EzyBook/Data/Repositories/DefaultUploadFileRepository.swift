//
//  DefaultUploadFileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import Foundation

final class DefaultUploadFileRepository: ProfileImageUploadRepository, ReviewImageUploadRepository {

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 프로필 이미지 업로드
    func requestUploadImage(_ router: UserRequest.Multipart) async throws -> UserImageUploadEntity {
        let data = try await networkService.fetchData(dto: ProfileImageUploadResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    func requestReviewUploadImage(_ router: ReViewRequest.Multipart) async throws -> ReviewImageEntity {
        
        let data = try await networkService.fetchData(dto: ReviewImageResponseDTO.self, router)
        
        return data.toEntity()
    }
    

}
