//
//  DefaultDetailFeatureService.swift
//  EzyBook
//
//  Created by youngkyun park on 7/30/25.
//

import Foundation

final class DefaultDetailFeatureService: DetailFeatureService {
    let chatRoom: ChatRoomServiceProtocol
    let favorite: FavoriteServiceProtocol
    
    init(chatRoom: ChatRoomServiceProtocol, favorite: FavoriteServiceProtocol) {
        self.chatRoom = chatRoom
        self.favorite = favorite
    }
    
}


final class ChatRoomService: ChatRoomServiceProtocol {
    
    private let createChatRoomUseCase: CreateChatRoomUseCase
    
    init(createChatRoomUseCase: CreateChatRoomUseCase) {
        self.createChatRoomUseCase = createChatRoomUseCase
    }
    
    func createOrGetRoomID(for userID: String) async throws -> String {
        let result = try await createChatRoomUseCase.execute(id: userID)
        return result.roomID
    }
    
    
    
}

final class FavoriteService: FavoriteServiceProtocol {
    
    private let activityKeepUseCase: ActivityKeepCommandUseCase
    
    init(activityKeepUseCase: ActivityKeepCommandUseCase) {
        self.activityKeepUseCase = activityKeepUseCase
    }
    
    
    func activtyKeep(id: String, status: Bool) async throws -> Bool {
        
        let result = try await activityKeepUseCase.execute(id: id, stauts: status)
        
        return result.keepStatus
    }
}
