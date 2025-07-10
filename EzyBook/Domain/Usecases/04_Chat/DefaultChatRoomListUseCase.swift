//
//  DefaultChatRoomListUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import Foundation

final class DefaultChatRoomListUseCase {
    
    private let repo: ChatRoomListRepository
    
    init(repo: ChatRoomListRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> [ChatRoomEntity] {
        
        let router = ChatRequest.Get.lookUpChatRoomList
        
        do {
            return try await
            self.repo.requesChatRoomList(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
}

