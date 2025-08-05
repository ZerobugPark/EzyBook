//
//  DefaultChatMessageRealmRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation
import RealmSwift


final class DefaultChatRoomRealmRepository: RealmRepository<ChatRoomTable> ,ChatMessageRealmRepository {
   
    
    func save(message: ChatEntity, myID: String) {
        save(chatList: [message], myID: myID)
    }
    
    
    func save(chatList: [ChatEntity], myID: String, retryCount: Int = 0) {
        getFileURL()

        let grouped = Dictionary(grouping: chatList, by: { $0.roomID })

        do {
            try realm.write {
                for (roomID, messages) in grouped {
                    // 메시지를 생성
                    let newMessages = messages.map { ChatMessageTable.from(entity: $0) }

                    // 마지막 메시지 추출
                    let latest = newMessages.sorted(by: { $0.createdAt > $1.createdAt }).first

                    // 기존 방 찾기 또는 생성
                    let room = realm.object(ofType: ChatRoomTable.self, forPrimaryKey: roomID)
                        ?? ChatRoomTable(
                            roomID: roomID,
                            opponentUserID: "",
                            lastMessage: latest?.content ?? "",
                            lastMessageTime: latest?.createdAt ?? Date(),
                            lastMessageSenderID: latest?.senderID ?? "",
                            unreadCount: 0,
                            messages: []
                        )

                    // 메시지 추가
                    room._messages.append(objectsIn: newMessages)

                    // 마지막 메시지 갱신
                    if let latest = latest {
                        room.lastMessage = latest.content
                        room.lastMessageTime = latest.createdAt
                        room.lastMessageSenderID = latest.senderID
                        
                        // 상대방 ID 지정
                          if let opponent = messages.first(where: { $0.sender.userID != myID })?.sender.userID {
                              room.opponentUserID = opponent
                          }
                        
                        /// 유저 정보 저장
                        let sender = messages.first(where: { $0.sender.userID == latest.senderID })?.sender
                        if let sender = sender {
                            saveUser(user: sender)
                        }
                        
                    }
                    
                    
                    realm.add(room, update: .modified)
                }
            }
        } catch {
            print(" Realm 저장 실패 - 재시도 \(retryCount)")

            if retryCount < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.save(chatList: chatList, myID: myID, retryCount: retryCount + 1)
                }
            } else {
                print(" Realm 저장 영구 실패. 수동 보정 필요.")
            }
        }
    }
    
    private func saveUser(user: UserInfoEntity) {
        do {
            try realm.write {
                if let existing = realm.object(ofType: UserInfoTable.self, forPrimaryKey: user.userID) {
                    // 변경 사항이 있을 때만 업데이트
                    if existing.nick != user.nick || existing.profileImageURL != user.profileImage {
                        existing.nick = user.nick
                        existing.profileImageURL = user.profileImage
                    }
                } else {
                    let newUser = UserInfoTable(
                        userID: user.userID,
                        nick: user.nick,
                        profileImageURL: user.profileImage
                    )
                    realm.add(newUser, update: .modified)
                }
            }
        } catch {
            print("❌ UserInfo 업데이트 실패: \(error)")
        }
    }
    
    /// 가장 최근 채팅 내역
//    func fetchLatestMessages(roomID: String, userID: String) -> ChatMessageEntity? {
//        let last = realm.objects(ChatMessageTable.self)
//            .filter("roomID == %@", roomID)
//            .sorted(byKeyPath: "createdAt", ascending: false)
//            .first
//        
//        return last?.toEntity(userID: userID)
//        
//    }
//    
    

    
    /// 채팅 내역 불러오기
//    func fetchMessageList(roomID: String, before: String?, limit: Int, userID: String) -> [ChatMessageEntity] {
//        
//        
//        var query = realm.objects(ChatMessageTable.self)
//            .filter ("roomID == %@", roomID)
//        
//        if let before {
//            query = query.filter("createdAt < $@", before)
//        }
//        
//        return Array(query
//            .sorted(byKeyPath: "createdAt", ascending: false)
//            .prefix(limit)
//            .reversed()
//            .map {
//                $0.toEntity(userID: userID)
//            }
//        )
//    }

    /// 나중에 비어있는방 제거
//    func cleanEmptyChatRooms() {
//        let emptyRooms = realm.objects(ChatRoomTable.self)
//            .filter("_messages.@count == 0")
//
//        try? realm.write {
//            realm.delete(emptyRooms)
//        }
//    }
    
}

// MARK: 채팅목록
extension DefaultChatRoomRealmRepository {
    /// 채팅 목록 불러오기
    func fetchLatestChatList() -> [LastMessageSummary] {
        let rooms = realm.objects(ChatRoomTable.self)
            .sorted(byKeyPath: "lastMessageTime", ascending: false)
        
        var result: [LastMessageSummary] = []

        for room in rooms {
            // sender 정보 조회
            let opponent = realm.object(ofType: UserInfoTable.self, forPrimaryKey: room.opponentUserID)
            
            let opponentInfo = OpponentSummary(
                userID: room.opponentUserID,
                nick: opponent?.nick ?? "알 수 없음",
                profileImageURL: opponent?.profileImageURL
            )

            result.append(LastMessageSummary(
                content: room.lastMessage,
                updateAt: room.lastMessageTime,
                unreadCount: room.unreadCount,
                opponentInfo: opponentInfo
            ))
        }

        return result
    }

}

