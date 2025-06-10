//
//  DefaultUploadFileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import Foundation

final class DefaultUploadFileRepository: ProfileUploadRepository {

    private let networkService: MultiPartNetworkSevice
    
    init(networkService: MultiPartNetworkSevice) {
        self.networkService = networkService
    }
    
    /// 이미지 업로드
    func requestUploadImage(_ router: UserPostRequest) async throws -> UserImageUploadEntity {
        let data = try await networkService.fetchMultiPartData(dto: ProfileImageUploadResponseDTO.self, router)
        
        return data.toEntity()
    }
    

}
