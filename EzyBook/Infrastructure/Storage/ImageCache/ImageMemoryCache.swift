//
//  ImageMemoryCache.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import SwiftUI

final class ImageMemoryCache {
 
    private let cache = NSCache<NSString, UIImage>()

    init() {            
        // 개수 기준으로 제한
        cache.countLimit = 100
        // 메모리 기준으로 제한.
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    
    /// 캐시 데이터 로드
    func get(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    /// 캐시 데이터 저장
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}
