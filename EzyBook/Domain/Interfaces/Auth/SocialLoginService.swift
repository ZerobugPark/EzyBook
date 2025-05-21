//
//  SocialLoginProvider.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

protocol SocialLoginService {
    func kakoLogin() async throws -> String
    func appleLogin() async throws -> String
}
