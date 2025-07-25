//
//  PaymentImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation

final class DefaultPaymentValidationUseCase: PaymentValidationUseCase {
    
    private let repo: PaymentReceiptOrderRepository
    
    init(repo: PaymentReceiptOrderRepository) {
        self.repo = repo
    }

}

extension DefaultPaymentValidationUseCase {
    func execute(impUid: String) async throws -> ReceiptOrderEntity {
        try await repo.requestPaymentValidation(impUid)
    }
}

