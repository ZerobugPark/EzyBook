//
//  UnReadChatTable.swift
//  EzyBook
//
//  Created by youngkyun park on 8/16/25.
//

import Foundation
import RealmSwift

final class UnReadChatTable: Object {
    @Persisted(primaryKey: true) var roomID: String
    @Persisted var count: Int
    
    
    convenience init(roomID: String, count: Int) {
        self.init()
        self.roomID = roomID
        self.count = count
    }
}

