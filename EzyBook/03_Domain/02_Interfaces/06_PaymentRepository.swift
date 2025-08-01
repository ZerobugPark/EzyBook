//
//  PaymentRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation

protocol PaymentReceiptOrderRepository {
    func requestPaymentValidation(_ impUid: String) async throws -> ReceiptOrderEntity
}

