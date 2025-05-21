//
//  NetworkManager.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

protocol HttpClient {
    func request<R: NetworkRouter>(_ router: R) async throws -> Data
}
