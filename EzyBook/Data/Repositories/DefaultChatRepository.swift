//
//  DefaultChatRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

struct DefaultChatRepository: ChatRoomRepository, ChatListRepository, ChatRoomListRepository {

    


    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    
    func requestCreateChatRoom(_ router: ChatRequest.Post) async throws -> ChatRoomEntity {
        
        let data = try await networkService.fetchData(dto: ChatRoomResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    func requestChatlist(_ router: ChatRequest.Get) async throws -> [ChatEntity] {
        
        let data = try await networkService.fetchData(dto: ChatListResponseDTO.self, router)
        
        return data.toEntity()
        
    }
 
    func requesChatRoomList(_ router: ChatRequest.Get) async throws -> [ChatRoomEntity] {
        
        let data = try await networkService.fetchData(dto: ChatRoomListResponseDTO.self, router)

        return data.toEntity()
        
    }

    
}
