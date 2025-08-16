//
//  DefaultChatMessageRealmRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation
import RealmSwift
import Combine


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
                            lastChatID: "",
                            lastMessage: latest?.content ?? "",
                            lastMessageTime: latest?.createdAt ?? Date(),
                            lastMessageSenderID: latest?.senderID ?? "",
                            unreadCount: 0,
                            files: [],
                            messages: []
                        )

                    // 메시지 추가 (중복 방지)
                    for message in newMessages {
                        realm.add(message, update: .modified)
                        if !room._messages.contains(where: { $0.chatID == message.chatID }) {
                            room._messages.append(message)
                        }
                    }

                    // 마지막 메시지 갱신
                    if let latest = latest {
                        room.lastChatID = latest.chatID
                        room.lastMessage = latest.content
                        room.lastMessageTime = latest.createdAt
                        room.lastMessageSenderID = latest.senderID
                        room.files = latest.files

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
        if let existing = realm.object(ofType: UserInfoTable.self, forPrimaryKey: user.userID) {
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
    
    // 가장 최근 채팅 내역
    func fetchLatestMessages(roomID: String, myID: String) -> ChatMessageEntity? {
        
        
        guard let room = realm.object(ofType: ChatRoomTable.self, forPrimaryKey: roomID) else {
            return nil
        }
        
        // 상대방 정보
        let opponent = realm.object(ofType: UserInfoTable.self, forPrimaryKey: room.opponentUserID)
        let opponentInfo = OpponentSummary(
            userID: room.opponentUserID,
            nick: opponent?.nick ?? "알 수 없음",
            profileImageURL: opponent?.profileImageURL
        )
        
        return ChatMessageEntity(
            chatID: room.lastChatID,
            content: room.lastMessage,
            createdAt: room.lastMessageTime,
            files: room.files,
            opponentInfo: opponentInfo,
            isMine: room.lastMessageSenderID == myID
        )
    }
    
    
    
    
    /// 채팅 내역 불러오기
    func fetchMessageList(roomID: String, before: String?, limit: Int, myID: String) -> [ChatMessageEntity] {
        
        
        guard let room = realm.object(ofType: ChatRoomTable.self, forPrimaryKey: roomID) else {
            return []
        }
        
        let opponent = realm.object(ofType: UserInfoTable.self, forPrimaryKey: room.opponentUserID)
        let opponentInfo = OpponentSummary(
            userID: room.opponentUserID,
            nick: opponent?.nick ?? "알 수 없음",
            profileImageURL: opponent?.profileImageURL
        )
        
        
        var messages = room.messages
        
        if let beforeDate = before?.toDate() {
            messages = messages.filter { $0.createdAt < beforeDate }
        }
        
        return messages
            .sorted(by: { $0.createdAt > $1.createdAt }) // 최신순 정렬
            .prefix(limit)
            .reversed() // UI는 오래된 순서대로
            .map {
                ChatMessageEntity(
                    chatID: $0.chatID,
                    content: $0.content,
                    createdAt: $0.createdAt,
                    files: $0.files,
                    opponentInfo: opponentInfo,
                    isMine: $0.senderID == myID
                )
            }
    }
    
    func chatRoomsPublisher() -> AnyPublisher<[LastMessageSummary], Never> {
        realm.objects(ChatRoomTable.self)
            .sorted(byKeyPath: "lastMessageTime", ascending: false)
            .collectionPublisher
            .map { rooms in
                rooms.map { room in
                    let opponent = self.realm.object(ofType: UserInfoTable.self,
                                                     forPrimaryKey: room.opponentUserID)
                    
                    let opponentInfo = OpponentSummary(
                        userID: room.opponentUserID,
                        nick: opponent?.nick ?? "알 수 없음",
                        profileImageURL: opponent?.profileImageURL
                    )
                    
                    return LastMessageSummary(
                        roomID: room.roomID,
                        content: room.lastMessage,
                        updateAt: room.lastMessageTime,
                        unreadCount: room.unreadCount,
                        opponentInfo: opponentInfo,
                        files: room.files
                    )
                }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
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
            
            result.append(
                LastMessageSummary(
                    roomID: room.roomID,
                    content: room.lastMessage,
                    updateAt: room.lastMessageTime,
                    unreadCount: room.unreadCount,
                    opponentInfo: opponentInfo,
                    files: room.files
                )
            )
        }
        
        return result
    }
    
        
    
}

