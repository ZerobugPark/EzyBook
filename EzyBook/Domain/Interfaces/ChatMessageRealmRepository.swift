//
//  ChatDataRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

protocol ChatMessageRealmRepository: Repository where T == ChatMessageTable {
    func save(chatList: [ChatMessageEntity], retryCount: Int)
    func fetchLatestMessages(roomID: String, userID: String) ->  ChatMessageEntity?
    func fetchMessageList(roomID: String, before: String?, limit: Int, userID: String) -> [ChatMessageEntity]
}

extension ChatMessageRealmRepository {
    func save(chatList: [ChatMessageEntity]) {
        save(chatList: chatList, retryCount: 0)
    }

}


protocol ChatRoomRealmRepository: Repository where T == ChatRoomTabel {
    func save(lastChat: [ChatRoomEntity])
    func fetchLastMessageList() -> [ChatRoomEntity]
}




