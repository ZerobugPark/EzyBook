//
//  DefaultChatMessageRealmRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

import RealmSwift




final class DefaultChatMessageRealmRepository: RealmRepository<ChatMessageTable> ,ChatMessageRealmRepository {
    
    func save(chatList: [ChatMessageEntity], retryCount: Int = 0) {
        getFileURL()
        let objects = chatList.map { ChatMessageTable.from(entity: $0) }
        
        do {
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            print(" Realm 저장 실패 - 재시도 \(retryCount)")
            
            if retryCount < 3 {
                // 약간의 딜레이 후 재시도
                // concurrency를 사용할 경우 메인쓰레드에 대해서 한번 더 명시를 해줘야 할 수 있기 때문에, GCD 사용
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.save(chatList: chatList, retryCount: retryCount + 1)
                }
            } else {
                print(" Realm 저장 영구 실패. 수동 보정 필요.")
            }
        }
        
    }
    

    /// 가장 최근 채팅 내역
    func fetchLatestMessages(roomID: String, userID: String) -> ChatMessageEntity? {
        let last = realm.objects(ChatMessageTable.self)
            .filter("roomID == %@", roomID)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .first
        
        return last?.toEntity(userID: userID)
        
    }
    

    
    /// 채팅 내역 불러오기
    func fetchMessageList(roomID: String, before: String?, limit: Int, userID: String) -> [ChatMessageEntity] {
        
        
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
                $0.toEntity(userID: userID)
            }
        )
    }
    
}

final class DefaultChatRoomRealmRepository: RealmRepository<ChatRoomTabel>, ChatRoomRealmRepository {
    
    func save(lastChat: [ChatRoomEntity]) {
        
        let objects = lastChat.map { ChatRoomTabel.from(entity: $0) }
        
        do {
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            print("렘 저장 실패")
        }
        
    }

    /// 마지막 채팅 목록
    func fetchLastMessageList() -> [ChatRoomEntity] {
        
        
        return realm.objects(ChatRoomTabel.self)
            .sorted(byKeyPath: "lastMessageCreatedAt", ascending: false)
            .map { $0.toEntity() }
        
        
        
    }
    
}

