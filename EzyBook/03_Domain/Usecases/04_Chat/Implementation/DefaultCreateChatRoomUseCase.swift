//
//  DefaultCreateChatRoomUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

/// 채팅방생성
final class DefaultCreateChatRoomUseCase: CreateChatRoomUseCase {
    
    private let repo: ChatRoomRepository
    
    init(repo: ChatRoomRepository) {
        self.repo = repo
    }
    

    
}

extension DefaultCreateChatRoomUseCase {
    func execute(id: String) async throws -> ChatRoomEntity {
        
        try await repo.requestCreateChatRoom(id)
    }
}
