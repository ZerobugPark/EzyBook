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

// 파일 업로드
protocol ChatUploadFileRepository {
    func requestUploadFile(_ id: String, _ url: URL) async throws -> FileResponseEntity
}

protocol ChatLoadPDFRepository {
    func requestLoadPDF(_ path: String) async throws -> Data
}

// 안읽은 채팅 내역 관련

protocol SaveUnReadChatMessage {
    func execute(roodID: String)
}

protocol ResetUnReadCount {
    func execute(roodID: String)
}


protocol GetUnReadChatCount {
    func execute(roodID: String) -> Int
}

