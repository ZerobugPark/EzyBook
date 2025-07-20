//
//  BannerResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import Foundation

struct BannerListResponseDTO: Decodable, EntityConvertible {
    let data: [BannerResponseDTO]
    
}

struct BannerResponseDTO: Decodable {
    
    let name: String
    let imageUrl: String
    let payload: PayloadResponseDTO
}

struct PayloadResponseDTO: Decodable {
    let type: String
    let value: String
}
