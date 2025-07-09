//
//  DefaultChatRealmDataRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

import RealmSwift




final class DefaultChatRealmDataRepository: RealmRepository<ChatMessageObject> ,ChatDataRepository {

    func save(chatList: [ChatMessageEntity]) {
        getFileURL()
        let objects = chatList.map { ChatMessageObject.from(entity: $0) }
        
        do {
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            print("렘 저장 실패")
        }
        
    }
    
    func getLastChatMessage(roomID: String) -> ChatMessageEntity? {
        
        guard let lastObject = realm.objects(ChatMessageObject.self)
            .filter ("roomID == %@", roomID)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .first else {
                return nil
            }
        
        return lastObject.toEntity()
        
    }
    
    func fetchMessageList(roomID: String, before: String?, limit: Int, opponentID: String) -> [ChatMessageEntity] {
        
        
        var query = realm.objects(ChatMessageObject.self)
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

