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
    
    func getLastChatMessage(roomId: String) -> ChatMessageEntity? {
        
        guard let lastObject = realm.objects(ChatMessageObject.self)
            .filter ("roomID == %@", roomId)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .first else {
                return nil
            }
        
        return lastObject.toEntity()
        
    }
    
}

