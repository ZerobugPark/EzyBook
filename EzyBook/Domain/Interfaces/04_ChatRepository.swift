//
//  04_ChatRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation


/// 채팅방 생성
protocol ChatRoomRepository {
    func requestCreateChatRoom(_ router: ChatRequest.Post) async throws -> ChatRoomEntity
}


/// 채팅 리스트
protocol ChatListRepository {
    func requestChatlist(_ router: ChatRequest.Get) async throws -> [ChatEntity] 
}

/// 채팅방 목록 조회
protocol ChatRoomListRepository {
    func requesChatRoomList(_ router: ChatRequest.Get) async throws -> [ChatRoomEntity]
}
