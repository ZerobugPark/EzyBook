//
//  ActivityPostTable.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import Foundation
import RealmSwift

/// 액티비티 게시물 작성 여부 판단
final class ActivityPostTable: Object {
    @Persisted(primaryKey: true) var activityID: String

    
    convenience init(activityID: String) {
        self.init()
        self.activityID = activityID
     
    }
}
