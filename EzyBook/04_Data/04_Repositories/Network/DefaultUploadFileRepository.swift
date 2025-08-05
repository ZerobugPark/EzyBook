//
//  DefaultUploadFileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

final class DefaultUploadFileRepository: ProfileImageUploadRepository, ReviewImageUploadRepository, PostUploadRepository {


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
    
    func requesPostUploadImages(_ images: [UIImage]) async throws -> FileResponseEntity {
        
        let router = ActivityPostRequest.Multipart.postImages(images: images)
        
        let data = try await networkService.fetchData(dto: FileResponseDTO.self, router)
        
        return data.toEntity()
            
    }
    
    func requesPostUploadVideos(_ videos: [Data]) async throws -> FileResponseEntity {
        
        let compressedVideos = await withTaskGroup(of: Data?.self) { group in
            for video in videos {
                group.addTask {
                    await video.downsized(toMaxSize: 5_000_000)
                }
            }

            var results: [Data] = []
            for await result in group {
                if let data = result {
                    results.append(data)
                }
            }
            return results
        }
        
        if compressedVideos.isEmpty {
            throw APIError(localErrorType: .uploadError)
        }

        let router = ActivityPostRequest.Multipart.postVideos(videos: compressedVideos)
        let data = try await networkService.fetchData(dto: FileResponseDTO.self, router)
        return data.toEntity()
    }
    

}
