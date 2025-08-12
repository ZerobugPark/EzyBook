//
//  DefaultDetailFeatureService.swift
//  EzyBook
//
//  Created by youngkyun park on 7/30/25.
//

import Foundation
import CoreLocation

final class DefaultDetailFeatureService: DetailFeatureService {
    
    
    let chatRoom: ChatRoomServiceProtocol
    let favorite: FavoriteServiceProtocol
    let location: LocationServiceProtocol
    
    init(chatRoom: ChatRoomServiceProtocol, favorite: FavoriteServiceProtocol, location: LocationServiceProtocol) {
        self.chatRoom = chatRoom
        self.favorite = favorite
        self.location = location
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
    private let activityKeppListUseCase: ActivityKeepListUseCase
    private let postKeepUseCase: PostLikeUseCase
    private let postLikeListUseCase: PostLikeListUseCase
    private let myPostUseCase: MyPostUseCase
    
    
    
    init(activityKeepUseCase: ActivityKeepCommandUseCase, activityKeppListUseCase: ActivityKeepListUseCase, postKeepUseCase: PostLikeUseCase, postLikeListUseCase: PostLikeListUseCase, myPostUseCase: MyPostUseCase) {
        self.activityKeepUseCase = activityKeepUseCase
        self.activityKeppListUseCase = activityKeppListUseCase
        self.postKeepUseCase = postKeepUseCase
        self.postLikeListUseCase = postLikeListUseCase
        self.myPostUseCase = myPostUseCase
    }
    
    
    func activtyKeep(id: String, status: Bool) async throws -> Bool {
        
        let result = try await activityKeepUseCase.execute(id: id, stauts: status)
        
        return result.keepStatus
    }
    
    func activtyKeepList(next: String?, limit: String) async throws -> ActivitySummaryListEntity {
        
        try await activityKeppListUseCase.execute(next: next, limit: limit)
    }
    
    
    func postLike(postID: String, status: Bool) async throws -> Bool {
        let result = try await postKeepUseCase.execute(postID: postID, status: status)
        
        return result.likeStatus
    }
    
    func postLikeList(next: String?, limit: String) async throws -> PostSummaryPaginationEntity {
        
        try await postLikeListUseCase.execute(next: next, limit: limit)
    }
    
    func myPostList(next: String?, limit: String, userID: String) async throws -> PostSummaryPaginationEntity {
        try await myPostUseCase.execute(next: next, limit: limit, userID: userID)
    }
}

final class LocationService: NSObject, LocationServiceProtocol {
    private var locationManager: CLLocationManager?
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }

    func fetchCurrentLocation() async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation?.resume(throwing: NSError(domain: "LocationError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Previous request cancelled."]))
            self.continuation = continuation

            guard let manager = self.locationManager else {
                continuation.resume(throwing: NSError(domain: "LocationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location manager not initialized."]))
                self.continuation = nil
                return
            }

            let status = manager.authorizationStatus
            switch status {
            case .notDetermined:
                print("🛰️ 권한 상태:", status.rawValue)
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                continuation.resume(throwing: NSError(domain: "LocationError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Location permission denied."]))
                self.continuation = nil
            @unknown default:
                continuation.resume(throwing: NSError(domain: "LocationError", code: -99, userInfo: [NSLocalizedDescriptionKey: "Unknown location auth status."]))
                self.continuation = nil
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status == .denied || status == .restricted {
            continuation?.resume(throwing: NSError(domain: "LocationError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Location permission denied."]))
            continuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let continuation = continuation else { return }

        if let coordinate = locations.first?.coordinate {
            continuation.resume(returning: coordinate)
        } else {
            continuation.resume(throwing: NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get location."]))
        }
        self.continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let continuation = continuation else { return }

        continuation.resume(throwing: error)
        self.continuation = nil
    }
}
