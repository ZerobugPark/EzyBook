//
//  DefaultChatRealmDataRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

import RealmSwift




final class DefaultChatRealmDataRepository: RealmRepository<ChatMessageObject> ,DefaultChatDataRepository {

    func save(chatList: [ChatMessageEntity]) {
        print(Thread.isMainThread)
        getFileURL()
        let objects = chatList.map { ChatMessageObject.from(entity: $0) }
        
        do {
            try realm.write {
                realm.add(objects)
            }
        } catch {
            print("렘 저장 실패")
        }
        
        
        
    }
    
}

