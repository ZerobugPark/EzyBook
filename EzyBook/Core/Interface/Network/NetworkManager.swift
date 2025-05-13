//
//  NetworkManager.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

protocol NetworkManager {
    func request<R: NetworkRouter>(_ router: R, completionHandler: @escaping (Result <Data, APIError>) -> Void)
}
