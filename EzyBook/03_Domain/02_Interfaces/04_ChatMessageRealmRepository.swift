//
//  ChatDataRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Combine

protocol ChatMessageRealmRepository: Repository where T == ChatRoomTable {
    
    func save(message: ChatEntity, myID: String) // 단건
    func save(chatList: [ChatEntity], myID: String, retryCount: Int) // 다건 저장
    func fetchLatestChatList() -> [LastMessageSummary]
    func fetchLatestMessages(roomID: String, myID: String) ->  ChatMessageEntity?
    func fetchMessageList(roomID: String, before: String?, limit: Int, myID: String) -> [ChatMessageEntity]
    func chatRoomsPublisher() -> AnyPublisher<[LastMessageSummary], Never>
}

extension ChatMessageRealmRepository {
    func save(chatList: [ChatEntity], myID: String) {
        save(chatList: chatList, myID: myID ,retryCount: 0)
    }
    

}



