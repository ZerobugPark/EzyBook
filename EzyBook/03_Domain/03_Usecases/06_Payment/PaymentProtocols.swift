//
//  PaymentProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation


protocol PaymentValidationUseCase {
    func execute(impUid: String) async throws -> ReceiptOrderEntity
}
