//
//  DefaultProfileSearchUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import Foundation


final class DefaultProfileSearchUseCase {
        
    let repo: ProfileSearchRepository
    
    init(repo: ProfileSearchRepository) {
        self.repo = repo
    }

    
}

extension DefaultProfileSearchUseCase {
    
    func execute(_ nick: String) async throws -> [UserInfoResponseEntity] {
    
        let router = UserRequest.Get.searchUser(nick: nick)
        
        do {
            let data = try await repo.requestSearchProfile(router)
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

