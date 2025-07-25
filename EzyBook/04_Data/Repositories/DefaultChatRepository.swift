//
//  DefaultChatRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

struct DefaultChatRepository: ChatRoomRepository, ChatListRepository, ChatRoomListRepository, ChatSendMessageRepository {

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 채팅방 생성
    func requestCreateChatRoom(_ router: ChatRequest.Post) async throws -> ChatRoomEntity {
        
        let data = try await networkService.fetchData(dto: ChatRoomResponseDTO.self, router)
        
        return data.toEntity()
    }
    ///채팅 내역 조회
    func requestChatlist(_ router: ChatRequest.Get) async throws -> [ChatEntity] {
        
        let data = try await networkService.fetchData(dto: ChatListResponseDTO.self, router)
        
        return data.toEntity()
        
    }
 
    /// 채팅방 조회
    func requestsChatRoomList(_ router: ChatRequest.Get) async throws -> [ChatRoomEntity] {
        
        let data = try await networkService.fetchData(dto: ChatRoomListResponseDTO.self, router)

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

