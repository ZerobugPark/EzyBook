//
//  DefaultChatListUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/2/25.
//

import Foundation

final class DefaultChatListUseCase {
    
    private let repo: ChatListRepository
    
    init(repo: ChatListRepository) {
        self.repo = repo
    }
    
    func execute(id: String, next: String?) async throws -> [ChatEntity] {
        
        let dto: ChatListRequestDTO
        if let next {
            dto = ChatListRequestDTO(next: next)
        } else {
            dto = ChatListRequestDTO(next: nil)
        }
        
        let router = ChatRequest.Get.lookUpChatList(id: id, dto: dto)
        
        do {
            return try await
            self.repo.requestChatlist(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
}

