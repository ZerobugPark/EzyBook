//
//  KakaoLoginRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

protocol KakaoLoginRepository {
    func requestKakaoLogin(_ token: String) async throws -> LoginEntity
}
