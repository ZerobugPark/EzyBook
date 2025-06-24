//
//  DefaultUploadFileUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import UIKit

struct DefaultUploadProfileFileUseCase {
    
    private let repo: ProfileImageUploadRepository
    
    init(repo: ProfileImageUploadRepository) {
        self.repo = repo
    }
    

    func execute(_ image: UIImage) async throws -> UserImageUploadEntity {
        
        let router = UserRequest.Multipart.profileImageUpload(image: image)
        
        do {
            
            let image = try await repo.requestUploadImage(router)
            return image

        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
        
    
}
