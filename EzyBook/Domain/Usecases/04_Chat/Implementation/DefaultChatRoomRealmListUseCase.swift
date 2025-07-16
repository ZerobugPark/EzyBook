//
//  DefaultChatRoomRealmListUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/12/25.
//

import Foundation

final class DefaultChatRoomRealmListUseCase {
    
    private let repo: any ChatRoomRealmRepository
    
    init(repo: any ChatRoomRealmRepository) {
        self.repo = repo
    }
    
    func executeSaveData(lastChat: [ChatRoomEntity]) {
        
        repo.save(lastChat: lastChat )
    }
    
    func excutFetchMessage() -> [ChatRoomEntity] {
        
        let data = repo.fetchLastMessageList()
        
        return data
        
    }
    

    

}
