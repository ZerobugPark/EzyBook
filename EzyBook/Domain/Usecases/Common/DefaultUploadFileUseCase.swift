//
//  DefaultUploadFileUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import UIKit

struct DefaultUploadFileUseCase {
    
    private let repo: ProfileUploadRepository
    
    init(repo: ProfileUploadRepository) {
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

extension DefaultUploadFileUseCase {
 
}
