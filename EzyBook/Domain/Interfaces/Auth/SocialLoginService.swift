//
//  SocialLoginProvider.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import AuthenticationServices
import Foundation

protocol SocialLoginService {
    func loginWithKakao() async throws -> String
    func loginWithApple(_ result: Result<ASAuthorization, any Error>) async throws -> (token: String, name: String?)
}
