//
//  ServiceProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/31/25.
//

import Foundation


/// 공통으로 사용 가능한 뷰모델

protocol DetailFeatureService {
    var chatRoom: ChatRoomServiceProtocol { get }
    var favorite: FavoriteServiceProtocol { get }
    //var thumbnail: ThumbnailServiceProtocol { get }
}


protocol ChatRoomServiceProtocol {
    func createOrGetRoomID(for userID: String) async throws -> String
}


protocol FavoriteServiceProtocol {
    func activtyKeep(id: String, status: Bool) async throws -> Bool
}


