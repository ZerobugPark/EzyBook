//
//  ChatListImplementation.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation

final class DefaultChatRoomListUseCase: ChatRemoteRoomListUseCase {
    
    private let repo: ChatRoomListRepository
    
    init(repo: ChatRoomListRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> [ChatRoomEntity] {
        
        let router = ChatRequest.Get.lookUpChatRoomList
        
        do {
            return try await
            self.repo.requestsChatRoomList(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
}

final class DefaultSaveLatestChatRoomUseCase: SaveRealmLatestChatRoomUseCase {

    private let repo: any ChatRoomRealmRepository
    
    init(repo: any ChatRoomRealmRepository) {
        self.repo = repo
    }
    
    
    
    func execute(lastChat: [ChatRoomEntity]) {
        
        repo.save(lastChat: lastChat )
    }
  
}

final class DefaultFetchChatRoomListUseCase: FetchRealmChatRoomListUseCase {

    

    private let repo: any ChatRoomRealmRepository
    
    init(repo: any ChatRoomRealmRepository) {
        self.repo = repo
    }
    
    
    func execute() -> [ChatRoomEntity] {
        
        let data = repo.fetchLastMessageList()
        return data
    }

  
}



