//
//  DefaultOrderListLookupUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 6/18/25.
//

import Foundation

final class DefaultOrderListLookupUseCase {
    
    private let repo: OrderListLookUpRepository
    
    init(repo: OrderListLookUpRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> [OrderEntity] {
        
        let router = OrderRequest.Get.order
        
        do {
            return try await self.repo.requestOrderListLookUp(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
}
