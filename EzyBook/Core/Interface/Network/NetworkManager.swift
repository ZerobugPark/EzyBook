//
//  NetworkManager.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

protocol NetworkManager {
    func callRequest<T: Decodable>(api: T, type: T.Type) -> Data
}
