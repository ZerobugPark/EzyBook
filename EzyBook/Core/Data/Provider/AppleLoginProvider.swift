//
//  AppleLoginProvider.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

final class AppleLoginProvider: SocialLoginProvider {
    
    func login() async throws -> String {
        return "mock_oauth_token"
    }
    
}
