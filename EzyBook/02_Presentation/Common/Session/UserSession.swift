//
//  UserSession.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation


final class UserSession {
    static let shared = UserSession()
    private init() {
        loadFromCache()
    }
    
    
    private(set) var currentUser: UserEntity?
    
    
    func update(_ user: UserEntity) {
        self.currentUser = user
        saveToCache(user)
    }
    
    func clear() {
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    // MARK: - Private: Caching
    private func saveToCache(_ user: UserEntity) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaultManager.currentUser = data
        }
    }
    
    /// UserDefaultLoad
    private func loadFromCache() {
        let data = UserDefaultManager.currentUser
        let cachedUser = try? JSONDecoder().decode(UserEntity.self, from: data)
        self.currentUser = cachedUser
    }
}
