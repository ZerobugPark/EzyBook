//
//  DefaultPaymentValidationUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation

final class DefaultPaymentValidationUseCase {
    
    private let repo: PaymentReceiptOrderRepository
    
    init(repo: PaymentReceiptOrderRepository) {
        self.repo = repo
    }
    
    func execute(dto: PaymentValidationDTO) async throws -> ReceiptOrderEntity {
        
        let router = PaymentRequest.Post.vaildation(dto: dto)
        
        do {
            return try await self.repo.requestPaymentValidation(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
}
