//
//  DefaultCreateOrderUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/16/25.
//

import Foundation


final class DefaultCreateOrderUseCase {
    
    private let repo: OrderCreateRepository
    
    init(repo: OrderCreateRepository) {
        self.repo = repo
    }
    
    func execute(dto: OrderCreateRequestDTO) async throws -> OrderCreateEntity {
        
        let router = OrderRequest.Post.order(dto: dto)
        
        do {
            return try await self.repo.requestOrderCreate(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
}

