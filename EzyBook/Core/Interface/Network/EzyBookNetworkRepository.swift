//
//  EzyBookNetworkRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/13/25.
//

import Foundation

protocol EzyBookNetworkRepository {
    func fetchData<T: Decodable ,R: NetworkRouter>(_ router: R, completionHandler: @escaping (Result<T, APIErrorResponse>) -> Void)
}
