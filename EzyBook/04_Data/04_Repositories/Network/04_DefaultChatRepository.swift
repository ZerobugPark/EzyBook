//
//  DefaultChatRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import UIKit

final class DefaultChatRepository: ChatRoomRepository, ChatListRepository, ChatRoomListRepository, ChatSendMessageRepository, ChatUploadImageRepository, ChatUploadFileRepository, ChatLoadPDFRepository {
   
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
    
    /// 이미지 업로드
    func requestUploadImage(_ id: String, _ files: [UIImage]) async throws -> FileResponseEntity {
        
        let router = ChatRequest.Multipart.uploadChatImages(id: id, image: files)
        let data = try await networkService.fetchData(dto: ChatFileResponseDTO.self, router)
        
        return data.toEntity()
    }

    /// 파일 업로드
    func requestUploadFile(_ id: String, _ url: URL) async throws -> FileResponseEntity {
        
        let router = ChatRequest.Multipart.uploadChatFile(id: id, file: url)
        let data = try await networkService.fetchData(dto: ChatFileResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    /// 파일 로드
    func requestLoadPDF(_ path: String) async throws -> Data {
        let router = ChatRequest.Get.lookUpPDF(path: path)
        let data = try await networkService.fetchPDFData(router)
    
        return data
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

