//
//  ImageMemoryCache.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import Foundation

final class ImageMemoryCache {
    
    /// NSCache<KeyType, ObjectType> 형태
    /// Memory Cache로 구현(이미지를 저장하는 건데, 디스크 캐시로 구현할 필요가 있을까?)
    private let cache = NSCache<NSString, NSData>()
    
    init() {
            
        // 개수 기준으로 제한
        cache.countLimit = 100
        // 메모리 기준으로 제한.
        //cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    

    
    /// 캐시 데이터 로드
    func get(forKey key: String) -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }
    /// 캐시 데이터 저장
    func set(_ data: Data, forKey key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }
}
