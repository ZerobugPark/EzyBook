//
//  AuthEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

struct RefreshEntity {
    let accessToken: String
    let refreshToken: String
    
    init(dto: AuthResponseDTO) {
        self.accessToken = dto.accessToken
        self.refreshToken = dto.refreshToken
    }
}
