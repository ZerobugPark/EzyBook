//
//  ActivityKeepCommandRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import Foundation

protocol ActivityKeepCommandRepository {
    func requestToggleKeep(_ router: ActivityPostRequest) async throws -> ActivityKeepEntity 
}
