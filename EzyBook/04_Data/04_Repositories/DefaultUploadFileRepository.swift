//
//  DefaultUploadFileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

final class DefaultUploadFileRepository: ProfileImageUploadRepository, ReviewImageUploadRepository {


    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 프로필 이미지 업로드
    func requestUploadImage(_ image: UIImage) async throws -> UserImageUploadEntity {
        
        let router = UserRequest.Multipart.profileImageUpload(image: image)
        
        let data = try await networkService.fetchData(dto: ProfileImageUploadResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    
    
    func requestReviewUploadImage(_ id: String, _ images: [UIImage]) async throws -> ReviewImageEntity {
       
        let router = ReviewRequest.Multipart.reviewFiles(id: id, image: images)
      
        let data = try await networkService.fetchData(dto: ReviewImageResponseDTO.self, router)
    
        return data.toEntity()
    }
    
    func requesPostUploadImages(_ images: [UIImage]) {
        
    }
    
    func requesPostUploadVideos(_ videos: [UIImage]) {
        
    }
    

}
