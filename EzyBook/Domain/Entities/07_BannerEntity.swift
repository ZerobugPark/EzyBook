//
//  07_BannerEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import SwiftUI



struct BannerEntity: Hashable, Equatable {
    
    let name: String
    let imageURL: String
    let payload: PayloadEntity
    var bannerImage: UIImage?
    
    init(dto: BannerResponseDTO) {
        self.name = dto.name
        self.imageURL = dto.imageUrl
        self.payload = PayloadEntity(dto: dto.payload)
    }
    
}

struct PayloadEntity: Hashable, Equatable  {
    let type: String
    let value: String
    
    init(dto: PayloadResponseDTO) {
        self.type = dto.type
        self.value = dto.value
    }
}
