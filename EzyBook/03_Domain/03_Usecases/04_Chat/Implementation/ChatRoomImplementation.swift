//
//  ChatRoomImplementation.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import UIKit
import Combine

// MARK: Remote

/// 메시지 전송 Clinet to Server
final class DefaultChatSendMessageUseCase: SendMessageUseCase {
    
    private let repo: any ChatSendMessageRepository
    
    init(repo: any ChatSendMessageRepository) {
        self.repo = repo
    }
    
 

}

extension DefaultChatSendMessageUseCase {
    func execute(roomId: String, content: String, files: [String]?) async throws -> ChatEntity {
        try await repo.requestSendMessage(roomId, content, files)
    }
}

    
    
/// 채팅방 내 채팅 내역 불러오기
final class DefaultFetchRemoteChatMessagesUseCase: FetchRemoteChatMessagesUseCase {
    
    private let repo: ChatListRepository
    
    init(repo: ChatListRepository) {
        self.repo = repo
    }
    
}
    
extension DefaultFetchRemoteChatMessagesUseCase {
    func execute(id: String, next: String?) async throws -> [ChatEntity] {
        
        try await repo.requestChatlist(id, next)

    }
}


/// 채팅방 목록 조회
final class DefaultChatRemoteRoomListUseCase: ChatRemoteRoomListUseCase {
    
    private let repo: ChatRoomListRepository
    
    init(repo: ChatRoomListRepository) {
        self.repo = repo
    }

     
        
}

extension DefaultChatRemoteRoomListUseCase {

    func execute() async throws -> [ChatRoomEntity] {
        try await repo.requestsChatRoomList()
    }
}


/// 이미지 업로드
final class DefaultChatImageUploadUseCase: ChatImageUploadUseCase {
    
    let repo: ChatUploadImageRepository
    
    init(repo: ChatUploadImageRepository) {
        self.repo = repo
    }
    
    
}

extension DefaultChatImageUploadUseCase {
    
    func execute(roodID: String, files: [UIImage]) async throws -> FileResponseEntity {
        try await repo.requestUploadImage(roodID, files)
    }
}

final class DefaultChatFileUploadUseCase: ChatFileUploadUseCase {
    
    let repo: ChatUploadFileRepository
    
    init(repo: ChatUploadFileRepository) {
        self.repo = repo
    }
    
    
}

extension DefaultChatFileUploadUseCase {
    
    func execute(roodID: String, file: URL) async throws -> FileResponseEntity {
        try await repo.requestUploadFile(roodID, file)
    }
}


/// 파일 데이터
final class DefaultFileLoadUseCase {
    
    
    private let repo: ChatLoadPDFRepository
    
    init(repo: ChatLoadPDFRepository) {
        self.repo = repo
    }
    
    func execute(path: String) async throws -> Data {
        try await repo.requestLoadPDF(path)
    }
    
    
}


// MARK: Local
// MARK: 메시지 내역 (Realm)
final class DefaultRealmFetchChatMessageListUseCase: FetchChatMessageListUseCase {
  
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }

}

extension DefaultRealmFetchChatMessageListUseCase {
    func excute(roomID: String, before: Date?, limit: Int, myID: String) -> [ChatMessageEntity] {
        let data = repo.fetchMessageList(roomID: roomID, before: before, limit: limit, myID: myID)

        return data
    }
}


/// 가장 최근 메시지 내역 (Realm)
final class DefaultRealmFetchLatestChatMessageUseCase: FetchLatestChatMessageUseCase {
    
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }


}
extension DefaultRealmFetchLatestChatMessageUseCase {
    func execute(roodID: String, myID: String) -> ChatMessageEntity? {
      
        let data = repo.fetchLatestMessages(roomID: roodID, myID: myID)
        return data
    }
}

//// MARK: 메시지 저장 (Realm)
final class DefaultRealmSaveChatMessageUseCase: SaveChatMessageUseCase {

    
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }
    

}
extension DefaultRealmSaveChatMessageUseCase {
    
    func execute(chatList: [ChatEntity], myID: String) {
        repo.save(chatList: chatList, myID: myID)
    }
    
    func execute(message: ChatEntity,  myID: String) {
        repo.save(message: message, myID: myID)
    }
    
}


// MARK: 가장 마지막 채팅 리스트 불러오기
final class DefaultFetchRealmChatRoomListUseCase: FetchRealmChatRoomListUseCase {
    
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }
    
}

extension DefaultFetchRealmChatRoomListUseCase {
    
    func execute() -> [LastMessageSummary]  {
        repo.fetchLatestChatList()
    }
    
    func publisher() -> AnyPublisher<[LastMessageSummary], Never> {
        repo.chatRoomsPublisher()
    }
}


// MARK: 안 읽은 채팅 내역

final class DefaultSaveUnReadChatMessage: SaveUnReadChatMessage {
    
    private let repo: any UnReadChatRepository
    
    init(repo: any UnReadChatRepository) {
        self.repo = repo
    }
    
}

extension DefaultSaveUnReadChatMessage {
    
    func execute(roodID: String) {
        repo.increment(roomID: roodID)
    }
}

final class DefaultResetUnReadCount: ResetUnReadCount {
    
    private let repo: any UnReadChatRepository
    
    init(repo: any UnReadChatRepository) {
        self.repo = repo
    }
    
}

extension DefaultResetUnReadCount {
    
    func execute(roodID: String) {
        repo.reset(roomID: roodID)
    }
    
}


final class DefaultGetUnReadChatCount: GetUnReadChatCount {
    
    private let repo: any UnReadChatRepository
    
    init(repo: any UnReadChatRepository) {
        self.repo = repo
    }
    
}

extension DefaultGetUnReadChatCount {
    func execute(roodID: String) -> Int {
        repo.total(for: roodID)
    }
    
}
