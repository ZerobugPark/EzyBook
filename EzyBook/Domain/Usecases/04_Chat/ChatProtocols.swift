//
//  ChatProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation


// MARK: 채팅방 관련 프로토콜

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

// MARK: 채팅 목록 관련 프로토콜

/// 채팅방 내역 조회 (Client <-> Server)
protocol ChatRemoteRoomListUseCase {
    func execute() async throws -> [ChatRoomEntity]
}

/// 마지막 채팅 내역 저장 (렘)
protocol SaveRealmLatestChatRoomUseCase {
    func execute(lastChat: [ChatRoomEntity])
}

/// 채팅방 별 가장 최근 채팅 내역 호출
protocol FetchRealmChatRoomListUseCase {
    func execute() -> [ChatRoomEntity]
}

