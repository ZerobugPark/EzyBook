//
//  MultiPartNetworkSevice.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

protocol MultiPartNetworkSevice: Sendable {
    func fetchMultiPartData<T: Decodable & EntityConvertible, R: NetworkRouter>(dto: T.Type ,_ router: R) async throws -> T
}
