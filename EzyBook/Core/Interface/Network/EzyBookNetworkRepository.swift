//
//  EzyBookNetworkRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/13/25.
//

import Foundation

protocol EzyBookNetworkRepository {
    func fetchData<T: Decodable & EntityConvertible, E: StructEntity ,R: NetworkRouter>(dto: T.Type, _ router: R, completionHandler: @escaping (Result<E, APIError>) -> Void) where T.T == E
}
