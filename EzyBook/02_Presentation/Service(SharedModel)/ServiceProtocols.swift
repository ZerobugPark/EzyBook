//
//  ServiceProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/31/25.
//

import Foundation
import CoreLocation

/// 공통으로 사용 가능한 뷰모델
protocol DetailFeatureService {
    var chatRoom: ChatRoomServiceProtocol { get }
    var favorite: FavoriteServiceProtocol { get }
    var location: LocationServiceProtocol { get }
    
}


protocol ChatRoomServiceProtocol {
    func createOrGetRoomID(for userID: String) async throws -> String
}


protocol FavoriteServiceProtocol {
    func activtyKeep(id: String, status: Bool) async throws -> Bool
    func activtyKeepList(next: String?, limit: String) async throws -> ActivitySummaryListEntity
}

protocol LocationServiceProtocol {
    func fetchCurrentLocation() async throws -> CLLocationCoordinate2D
}

// MARK: 게시글 관련 댓글 서비스 뷰모델
protocol PostFeatureService {
    var write: PostWriteServiceProtocol { get }
    var delete: PostDeleteServiceProtocol { get }
    var modify: PostModifyServiceProtocol { get }
}

protocol PostWriteServiceProtocol {
    func writeComment(postID: String, parentID: String?, content: String) async throws -> ReplyEntity
}

protocol PostDeleteServiceProtocol {
    func deleteComment(postID: String, commentID: String) async throws
}

protocol PostModifyServiceProtocol {
    func modifyCommnet(postID: String, commnetID: String, text: String) async throws -> ReplyEntity
}




