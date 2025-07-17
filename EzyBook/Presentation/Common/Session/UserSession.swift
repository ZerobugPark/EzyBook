//
//  UserSession.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation


final class UserSession {
    static let shared = UserSession()
    private init() {}
    
    private(set) var currentUser: UserEntity?
    
    
    func update(_ user: UserEntity) {
        self.currentUser = user
    }
}
