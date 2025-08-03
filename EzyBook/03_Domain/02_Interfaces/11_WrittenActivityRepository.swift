//
//  11_WrittenActivityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import Foundation

protocol WrittenActivityRealmRepository: Repository where T == ActivityPostTable {
    func save(activityID: String, retryCount: Int)
    func fetchActivityWrittenList() -> [String]
}

extension WrittenActivityRealmRepository {
    func save(activityID: String) {
        save(activityID: activityID, retryCount: 0)
    }

}
