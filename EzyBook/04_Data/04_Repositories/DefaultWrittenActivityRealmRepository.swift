//
//  DefaultWrittenActivityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import Foundation
import RealmSwift

final class DefaultWrittenActivityRealmRepository: RealmRepository<ActivityPostTable>, WrittenActivityRealmRepository {
    
    func save(activityID: String, retryCount: Int = 0) {
        getFileURL()
        let objects = ActivityPostTable(activityID: activityID)
        
        do {
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            print(" Realm 저장 실패 - 재시도 \(retryCount)")
            
            if retryCount < 3 {
                // 약간의 딜레이 후 재시도
                // concurrency를 사용할 경우 메인쓰레드에 대해서 한번 더 명시를 해줘야 할 수 있기 때문에, GCD 사용
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.save(activityID: activityID, retryCount: retryCount + 1)
                }
            } else {
                print(" Realm 저장 영구 실패. 수동 보정 필요.")
            }
        }
        
    }
    
    func fetchActivityWrittenList() -> [String] {
        let results = realm.objects(ActivityPostTable.self)
        
        return results.map { $0.activityID }
    }

    
    
}

