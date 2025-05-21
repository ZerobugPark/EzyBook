//
//  TokenRefreshScheduler.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

protocol TokenRefreshScheduler {
    func start(refreshAction: @escaping () async -> Void)
    func stop()
}

