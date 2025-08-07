//
//  NetworkService.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

/// Sendable 동시성에서 안전한 타입이라고 명시
protocol NetworkService: Sendable {
    func fetchData<T: Decodable & EntityConvertible, R: NetworkRouter>(dto: T.Type ,_ router: R) async throws -> T
    func fetchPDFData<R: NetworkRouter>(_ router: R) async throws -> Data
}
