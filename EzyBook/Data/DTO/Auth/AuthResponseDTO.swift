//
//  AuthResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

struct AuthResponseDTO: Decodable, EntityConvertible {
    let accessToken: String
    let refreshToken: String
}
