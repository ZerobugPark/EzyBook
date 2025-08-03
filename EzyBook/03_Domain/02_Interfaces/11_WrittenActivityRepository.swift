//
//  11_WrittenActivityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import Foundation

protocol WrittenActivityRepository: Repository where T == ActivityPostTable {
    func save(activityID: String, retryCount: Int)
    func fetchActivityWrittenList() -> [String]
}

extension WrittenActivityRepository {
    func save(activityID: String) {
        save(activityID: activityID, retryCount: 0)
    }

}
