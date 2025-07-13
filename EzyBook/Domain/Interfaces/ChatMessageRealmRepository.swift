//
//  ChatDataRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

protocol ChatMessageRealmRepository: Repository where T == ChatMessageTable {
    func save(chatList: [ChatMessageEntity], retryCount: Int)
    func fetchLatestMessages(roomID: String, limit: Int, opponentID: String) -> [ChatMessageEntity]
    func fetchMessageList(roomID: String, before: String?, limit: Int, opponentID: String) -> [ChatMessageEntity]
}

extension ChatMessageRealmRepository {
    func save(chatList: [ChatMessageEntity]) {
        save(chatList: chatList, retryCount: 0)
    }
    
    func fetchLatestMessages(roomID: String, opponentID: String) -> [ChatMessageEntity] {
        fetchLatestMessages(roomID: roomID, limit: 30, opponentID: opponentID)
    }
}


protocol ChatRoomRealmRepository: Repository where T == ChatRoomTabel {
    func save(lastChat: [ChatRoomEntity])
    func fetchLastMessageList() -> [ChatRoomEntity]
}




