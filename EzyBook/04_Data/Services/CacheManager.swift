//
//  CacheManager.swift
//  EzyBook
//
//  Created by youngkyun park on 7/26/25.
//

import Foundation

protocol CacheManageable {
    func cleanUpDiskCache() async

 
}

final class CacheManager: CacheManageable {

    
    
    private let imageCache: ImageCache
    
    init(imageCache: ImageCache) {
        self.imageCache = imageCache
    }
    
    func cleanUpDiskCache() async {
        await imageCache.cleanUpDiskCache()
    }
    

    
}
