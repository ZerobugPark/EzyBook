//
//  DefaultProfileLookUpUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import Foundation

final class DefaultProfileLookUpUseCase {
        
    let repo: ProfileLookupRepository
    
    init(repo: ProfileLookupRepository) {
        self.repo = repo
    }

    
}

// MARK: Login
extension DefaultProfileLookUpUseCase {
    
    func execute() async throws -> ProfileLookUpEntity {
    
        let router = UserRequest.Get.profileLookUp
        
        do {
            let data = try await repo.requestProfileLookUp(router)
            return data
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }

}

