//
//  06_PaymentResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation

extension PaymentLookUpResponseDTO {
    func toEntity() -> PaymentLookUpEntity {
        PaymentLookUpEntity.init(dto: self)
    }
}

extension ReceiptOrderResponseDTO {
    func toEntity() -> ReceiptOrderEntity {
        ReceiptOrderEntity.init(dto: self)
    }
}
