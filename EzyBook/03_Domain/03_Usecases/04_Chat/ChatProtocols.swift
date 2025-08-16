//
//  ChatProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import UIKit
import Combine


// MARK: 채팅방 관련 프로토콜

/// 채팅방 생성
protocol CreateChatRoomUseCase {
    func execute(id: String) async throws -> ChatRoomEntity
}

/// 메시지 송신
protocol SendMessageUseCase {
    func execute(roomId: String, content: String, files: [String]?) async throws -> ChatEntity
}

protocol ChatImageUploadUseCase {
    func execute(roodID: String, files: [UIImage]) async throws -> FileResponseEntity
}


protocol ChatFileUploadUseCase {
    func execute(roodID: String, file: URL) async throws -> FileResponseEntity
}



// MARK: 채팅 목록 관련 프로토콜

// MARK: 서버
protocol ChatRemoteRoomListUseCase {
    func execute() async throws -> [ChatRoomEntity]
}



// MARK: Realm

/// 채팅방 별 가장 최근 채팅 내역 호출
protocol FetchRealmChatRoomListUseCase {
    func execute() -> [LastMessageSummary]
    func publisher() -> AnyPublisher<[LastMessageSummary], Never>
}

/// 메시지 저장
protocol SaveChatMessageUseCase {
    func execute(chatList: [ChatEntity], myID: String)
    func execute(message: ChatEntity,  myID: String)
}

/// 최신 메시지 조회
protocol FetchLatestChatMessageUseCase {
    func execute(roodID: String, myID: String) -> ChatMessageEntity?
}

/// 메시지 내역 조회
protocol FetchChatMessageListUseCase {
    func excute(roomID: String, before: String?, limit: Int, myID: String) -> [ChatMessageEntity] 
}

protocol FetchRemoteChatMessagesUseCase {
    func execute(id: String, next: String?) async throws -> [ChatEntity]
}
