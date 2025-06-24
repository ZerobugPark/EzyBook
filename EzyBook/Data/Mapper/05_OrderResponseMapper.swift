//
//  OrderResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 6/16/25.
//

import Foundation


extension OrderCreateResponseDTO {
    func toEntity() -> OrderCreateEntity {
        OrderCreateEntity.init(dto: self)
    }
}

extension OrderListResponseDTO {
    func toEntity() -> [OrderEntity] {
        self.data.map { OrderEntity(dto: $0) }
    }
}
