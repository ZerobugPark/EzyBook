//
//  ChatDataRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

protocol ChatDataRepository: Repository where T == ChatMessageObject {
    func save(chatList: [ChatMessageEntity])
    func getLastChatMessage(roomID: String) -> ChatMessageEntity?
    func fetchMessageList(roomID: String, before: String?, limit: Int, opponentID: String) -> [ChatMessageEntity]
}
