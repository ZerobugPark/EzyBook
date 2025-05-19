//
//  SocialLoginProvider.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

protocol SocialLoginProvider {
    func login() async throws -> String
}
