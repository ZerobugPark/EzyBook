//
//  04_ChatRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

protocol ChatRoomRepository {
    func requestChatRoom(_ router: ChatRequest.Post) async throws -> ChatRoomEntity
}

protocol ChatListRepository {
    func requestChatlist(_ router: ChatRequest.Get) async throws -> [ChatEntity] 
}
