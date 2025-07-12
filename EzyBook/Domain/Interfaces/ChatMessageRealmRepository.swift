//
//  ChatDataRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

protocol ChatMessageRealmRepository: Repository where T == ChatMessageTable {
    func save(chatList: [ChatMessageEntity])
    func getLastChatMessage(roomID: String) -> ChatMessageEntity?
    func fetchMessageList(roomID: String, before: String?, limit: Int, opponentID: String) -> [ChatMessageEntity]
}


protocol ChatRoomRealmRepository: Repository where T == ChatRoomTabel {
    func save(lastChat: [ChatRoomEntity])
    func fetchLastMessageList() -> [ChatRoomEntity]
}




