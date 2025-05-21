//
//  NetworkService.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

protocol NetworkService {
    func fetchData<T: Decodable & EntityConvertible, R: NetworkRouter>(dto: T.Type ,_ router: R) async throws -> T
}
