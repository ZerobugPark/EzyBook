//
//  04_ChatRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import UIKit


/// 채팅방 생성
protocol ChatRoomRepository {
    func requestCreateChatRoom(_ id: String) async throws -> ChatRoomEntity
}


/// 채팅 리스트
protocol ChatListRepository {
    func requestChatlist(_ id: String, _ next: String?) async throws -> [ChatEntity] 
}

/// 채팅방 목록 조회
protocol ChatRoomListRepository {
    func requestsChatRoomList() async throws -> [ChatRoomEntity]
}

/// 메시지 전송
protocol ChatSendMessageRepository {
    func requestSendMessage(_ roomId: String, _ content: String, _ files: [String]?) async throws -> ChatEntity
}


/// 이미지 업로드
protocol ChatUploadImageRepository {
    func requestUploadImage(_ id: String, _ files: [UIImage]) async throws -> FileResponseEntity
}
