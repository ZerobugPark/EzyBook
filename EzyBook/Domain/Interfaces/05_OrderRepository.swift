//
//  OrderRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/16/25.
//

import Foundation

/// 신규 액티비티 및 액티비티 검색 공용
protocol OrderCreateRepository {
    func requestOrderCreate(_ router: OrderRequest.Post) async throws -> OrderCreateEntity
}
