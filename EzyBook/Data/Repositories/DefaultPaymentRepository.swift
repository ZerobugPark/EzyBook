//
//  DefaultPaymentRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation

final class DefaultPaymentRepository: PaymentReceiptOrderRepository {

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 결제 영수증 검증
    func requestPaymentValidation(_ router: PaymentRequest.Post) async throws -> ReceiptOrderEntity {
        let data = try await networkService.fetchData(dto: ReceiptOrderResponseDTO.self, router)
        return data.toEntity()
    }
    

}
