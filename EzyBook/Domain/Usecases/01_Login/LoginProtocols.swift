//
//  LoginProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation
import AuthenticationServices

protocol AppleLogin {
    func execute(_ result:  Result<ASAuthorization, any Error>) async throws -> UserEntity
}

protocol KakaoLogin {
    func execute() async throws -> UserEntity
}
