//
//  DefaultCreateChatRoomUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

final class DefaultCreateChatRoomUseCase {
    
    private let repo: ChatRoomRepository
    
    init(repo: ChatRoomRepository) {
        self.repo = repo
    }
    
    func execute(id: String) async throws -> ChatRoomEntity {
        
        let dto = ChatRoomLookUpRequestDTO(opponentID: id)
        let router = ChatRequest.Post.makeChat(dto: dto )
        
        do {
            return try await repo.requestCreateChatRoom(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
}
