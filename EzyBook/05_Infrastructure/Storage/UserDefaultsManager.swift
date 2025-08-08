//
//  UserDefaultsManager.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import Foundation

@propertyWrapper struct EzyBookUserDefaultManager<T> {
    
    let key: String
    let empty: T
    
    init(key: String, empty: T) {
        self.key = key
        self.empty = empty
    }
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? empty
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
}

enum UserDefaultManager {
    enum Key: String {
        case etag
        case currentUser
        case userLocation
        case fcmToken
        
    }
    
    @EzyBookUserDefaultManager(key: Key.etag.rawValue, empty: [:])
    static var etag: [String: String]
    
    @EzyBookUserDefaultManager(key: Key.currentUser.rawValue, empty: Data())
    static var currentUser: Data
    
    
    @EzyBookUserDefaultManager(key: Key.userLocation.rawValue, empty: Data())
    static var userLocation: Data
    
    @EzyBookUserDefaultManager(key: Key.fcmToken.rawValue, empty: "")
    static var fcmToken: String
    
}

