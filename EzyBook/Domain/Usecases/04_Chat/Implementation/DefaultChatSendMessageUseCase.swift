//
//  DefaultChatSendMessageUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/16/25.
//

import Foundation

final class DefaultChatSendMessageUseCase: SendMessageUseCase {
    
    private let repo: any ChatSendMessageRepository
    
    init(repo: any ChatSendMessageRepository) {
        self.repo = repo
    }
    
    func execute(roomId: String, content: String, files: [String]?) async throws -> ChatEntity {
    
        do {
            return try await repo.requestSendMessage(roomId, content, files)
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }

}

