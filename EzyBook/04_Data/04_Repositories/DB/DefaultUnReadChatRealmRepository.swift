//
//  DefaultUnReadChatRealmRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/16/25.
//

import Foundation
import RealmSwift

final class DefaultUnReadChatRealmRepository: RealmRepository<UnReadChatTable>, UnReadChatRepository {

    
    func increment(roomID: String) {
        do {
            
            try realm.write {
                let obj = realm.object(ofType: UnReadChatTable.self, forPrimaryKey: roomID) ?? UnReadChatTable(roomID: roomID, count: 0)
                    
                obj.count += 1
                
                realm.add(obj, update: .modified)
            }
        } catch {
            print("❌ Unread increment failed:", error)
        }
    }
    
    func reset(roomID: String) {
        do {
            
            try realm.write {
                let obj = realm.object(ofType: UnReadChatTable.self, forPrimaryKey: roomID) ?? UnReadChatTable(roomID: roomID, count: 0)
                obj.count = 0
                
                realm.add(obj, update: .modified)
            }
        } catch {
            print("❌ Unread reset failed:", error)
        }
    }
    
    func total(for roomID: String) -> Int {
        guard let unread = realm.object(ofType: UnReadChatTable.self, forPrimaryKey: roomID) else {
            return 0
        }
        return unread.count
    }

    
}
