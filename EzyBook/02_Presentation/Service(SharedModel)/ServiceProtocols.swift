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
}

protocol LocationServiceProtocol {
    func fetchCurrentLocation() async throws -> CLLocationCoordinate2D
}


