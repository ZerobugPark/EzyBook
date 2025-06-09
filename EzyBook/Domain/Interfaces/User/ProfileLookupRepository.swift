//
//  ProfileLookupRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import Foundation

protocol ProfileLookupRepository {
    func requestProfileLookUp(_ router: UserGetRequest) async throws -> ProfileLookUpEntity
}

