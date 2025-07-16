//
//  ChatRoomProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation

/// 메시지 송신
protocol SendMessageUseCase {
    func execute(roomId: String, content: String, files: [String]?) async throws -> ChatEntity
}

/// 메시지 저장
protocol SaveChatMessageUseCase {
    func execute(chatList: [ChatMessageEntity])
}

/// 최신 메시지 조회
protocol FetchLatestChatMessageUseCase {
    func execute(roodID: String, userID: String) -> ChatMessageEntity?
}

/// 메시지 내역 조회
protocol FetchChatMessageListUseCase {
    func excute(roomID: String, before: String?, limit: Int, userID: String) -> [ChatMessageEntity]
}

protocol FetchRemoteChatMessagesUseCase {
    func execute(id: String, next: String?) async throws -> [ChatEntity]
}
