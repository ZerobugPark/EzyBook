//
//  AuthResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

// MARK: AuthResponse Mapper
extension AuthResponseDTO {
    func toEntity() -> RefreshEntity {
        RefreshEntity.init(dto: self)
    }
}



