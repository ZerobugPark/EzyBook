//
//  ChatMessageTabel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/1/25.
//

import Foundation
import RealmSwift

final class ChatMessageObject: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var roomID: String  // 🔗 ChatRoomObject와 연결
    @Persisted var content: String
    @Persisted var createdAt: Date
    @Persisted var files: List<String>
    @Persisted var senderID: String
    @Persisted var senderNick: String
}
