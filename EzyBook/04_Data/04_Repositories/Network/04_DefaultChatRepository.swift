//
//  DefaultChatRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

final class DefaultChatRepository: ChatRoomRepository, ChatListRepository, ChatRoomListRepository, ChatSendMessageRepository {
 

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 채팅방 생성
    func requestCreateChatRoom(_ id: String) async throws -> ChatRoomEntity {
        
        let dto = ChatRoomLookUpRequestDTO(opponentID: id)
        let router = ChatRequest.Post.makeChat(dto: dto )
        
        let data = try await networkService.fetchData(dto: ChatRoomResponseDTO.self, router)
        
        return data.toEntity()
    }
    ///채팅 내역 조회
    func requestChatlist(_ id: String, _ next: String?) async throws -> [ChatEntity] {
        
        let dto: ChatListRequestDTO
        if let next {
            dto = ChatListRequestDTO(next: next)
        } else {
            dto = ChatListRequestDTO(next: nil)
        }
        
        let router = ChatRequest.Get.lookUpChatList(id: id, dto: dto)
        
        let data = try await networkService.fetchData(dto: ChatListResponseDTO.self, router)
        
        return data.toEntity()
        
    }
 
    
    /// 메시지 전송
    /// roomId: String, content: String, files: [String]? = nil
    func requestSendMessage(_ roomId: String, _ content: String, _ files: [String]?) async throws -> ChatEntity {
        
        let dto = ChatSendMessageRequestDTO(content: content, files: files)
        let router = ChatRequest.Post.sendChat(roomId: roomId, dto: dto)
        
        
        ///_ router: ChatRequest.Post
        let data = try await networkService.fetchData(dto: ChatResponseDTO.self, router)
        
        return data.toEntity()
    }

    
}

// MARK: 채팅방 목록

extension DefaultChatRepository {
    /// 채팅방 목록  조회
    func requestsChatRoomList() async throws -> [ChatRoomEntity] {
        
        let router = ChatRequest.Get.lookUpChatRoomList
        
        let data = try await networkService.fetchData(dto: ChatRoomListResponseDTO.self, router)

        return data.toEntity()
        
    }
}

