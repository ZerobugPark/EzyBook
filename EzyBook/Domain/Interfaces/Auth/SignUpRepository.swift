//
//  SignUpRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

protocol SignUpRepository {
    func verifyEmailAvailability(_ email: String) async throws
    func signUp(_ router: UserRequest) async throws
}
