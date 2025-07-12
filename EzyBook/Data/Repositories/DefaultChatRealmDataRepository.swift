//
//  DefaultChatMessageRealmRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

import RealmSwift




final class DefaultChatMessageRealmRepository: RealmRepository<ChatMessageTable> ,ChatMessageRealmRepository {

    func save(chatList: [ChatMessageEntity]) {
        getFileURL()
        let objects = chatList.map { ChatMessageTable.from(entity: $0) }
        
        do {
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            print("렘 저장 실패")
        }
        
    }
    
    func getLastChatMessage(roomID: String) -> ChatMessageEntity? {
        
        guard let lastObject = realm.objects(ChatMessageTable.self)
            .filter ("roomID == %@", roomID)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .first else {
                return nil
            }
        
        return lastObject.toEntity()
        
    }
    
    func fetchMessageList(roomID: String, before: String?, limit: Int, opponentID: String) -> [ChatMessageEntity] {
        
        
        var query = realm.objects(ChatMessageTable.self)
            .filter ("roomID == %@", roomID)
        
        if let before {
            query = query.filter("createdAt < $@", before)
        }
        
        return Array(query
            .sorted(byKeyPath: "createdAt", ascending: false)
            .prefix(limit)
            .reversed()
            .map {
                $0.toEntity(opponentID: opponentID)
            }
        )
    }
    
}

final class DefaultChatRoomRealmRepository: RealmRepository<ChatRoomTabel>, ChatRoomRealmRepository {
    
    func save(lastChat: [ChatRoomEntity]) {
        getFileURL()
        
        let objects = lastChat.map { ChatRoomTabel.from(entity: $0) }
        
        do {
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            print("렘 저장 실패")
        }
        
    }
    
    func fetchLastMessageList() -> [ChatRoomEntity] {
        
        
        return realm.objects(ChatRoomTabel.self)
            .sorted(byKeyPath: "lastMessageCreatedAt", ascending: false)
            .map { $0.toEntity() }

    

    }
    
}

