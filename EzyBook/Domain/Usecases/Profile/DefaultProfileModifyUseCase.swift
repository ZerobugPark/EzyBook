//
//  DefaultProfileModifyUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

final class DefaultProfileModifyUseCase {
        
    let repo: ProfileModifyRepository
    
    init(repo: ProfileModifyRepository) {
        self.repo = repo
    }

    
}

extension DefaultProfileModifyUseCase {
    
    func execute(_ dto: ProfileModifyRequestDTO) async throws -> ProfileLookUpEntity {
    
        let router = UserRequest.Put.profileModify(body: dto)
        
        do {
            let data = try await repo.requestModifyProfile(router)
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


