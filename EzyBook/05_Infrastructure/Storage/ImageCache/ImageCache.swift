//
//  ImageCache.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import SwiftUI

final class ImageCache {
    private let memory = ImageMemoryCache()
    private let disk = ImageDiskCache()

    // 메모리에서 UIImage 조회
    func get(forKey key: String) -> UIImage? {
        return memory.get(forKey: key)
    }

    // 디스크에서 원본 데이터 조회
    func getData(forKey key: String) -> Data? {
        return disk.get(forKey: key)
    }

    // 메모리에 이미지 저장
    func set(_ image: UIImage, forKey key: String) {
        memory.set(image, forKey: key)
    }

    // 디스크에 원본 데이터 저장
    func setData(_ data: Data, forKey key: String) {
        disk.set(data, forKey: key)
    }

    func clearAll() {
        memory.clear()
        disk.clear()
    }

    func cleanUpDiskCache() async {
        print(#function, "호출됨")
        await disk.cleanUp()
    }
}

