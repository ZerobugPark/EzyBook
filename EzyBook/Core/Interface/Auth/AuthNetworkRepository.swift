//
//  EzyBookAuthNetworkRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

protocol AuthNetworkRepository {
    func kakoLogin(_ token: String) async throws
}
