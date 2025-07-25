//
//  07_BannerMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import Foundation

extension BannerListResponseDTO {
    
    func toEntity() -> [BannerEntity] {
        self.data.map {
            BannerEntity(dto: $0)
        }
    }
}
