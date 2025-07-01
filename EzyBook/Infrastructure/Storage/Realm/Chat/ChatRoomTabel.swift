//
//  ChatRoomTabel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/1/25.
//

import Foundation
import RealmSwift

final class ChatRoomTabel: Object {
    @Persisted(primaryKey: true) var roomID: String
    @Persisted var opponentID: String   // 상대방 유저 ID
    @Persisted var opponentNick: String
    @Persisted var lastMessage: String?
    @Persisted var lastMessageAt: Date?
    
}

