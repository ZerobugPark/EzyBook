//
//  RealmRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/1/25.
//


import Foundation
import RealmSwift

protocol Repository {
    associatedtype T: Object
    func getFileURL()
    func create(_ item: T)
    
    func fatchAll() -> Results<T>
    func findById(_ id: Any) -> T?
    func update(_ item: T)
    func delete(_ item: T)
    func removeAll()
}

class RealmRepository<T: Object>: Repository {
    let realm = try! Realm()

    func getFileURL() {
        print(realm.configuration.fileURL)
    }
    
    func create(_ item: T) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Realm create fail")
        }
        
    }
    
    func fatchAll() -> Results<T> {
        return realm.objects(T.self)
    }
    
    func findById(_ id: Any) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: id)
    }
    
    func update(_ item: T) {
        do {
            try realm.write {
                realm.add(item, update: .modified)
            }
        } catch {
            print("Realm update fail")
        }
    }
    
    func delete(_ item: T) {
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Realm delete fail")
        }
    }
    
    func removeAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll() // ✅ 모든 데이터 삭제
            }
            print("Realm 데이터 전부 삭제 완료")
        } catch {
            print("Realm 데이터 삭제 실패: \(error.localizedDescription)")
        }
    }
    
}
