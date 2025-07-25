//
//  ImageDiskCache.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import Foundation


final class ImageDiskCache {
    private let directory: URL
    private let maxCacheSize: UInt64 = 300 * 1024 * 1024 // 300MB
    private let maxFileAge: TimeInterval = 7 * 24 * 60 * 60 // 7일

    init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        directory = base.appendingPathComponent("ImageDiskCache") // 디스크 캐시 경로
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func get(forKey key: String) -> Data? {
        let path = directory.appendingPathComponent(key.sha256())
        return try? Data(contentsOf: path)
    }

    func set(_ data: Data, forKey key: String) {
        let path = directory.appendingPathComponent(key.sha256())
        try? data.write(to: path)
    }
    
    func clear() {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: []) else {
            return
        }

        for fileURL in files {
            try? fileManager.removeItem(at: fileURL)
        }
    }
    
    func cleanUp() async {
        let directory = self.directory
        let maxFileAge = self.maxFileAge
        let maxCacheSize = self.maxCacheSize

        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let fileManager = FileManager.default

                guard let files = try? fileManager.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                    options: []
                ) else {
                    continuation.resume()
                    return
                }
                    
                let expirationDate = Date().addingTimeInterval(-maxFileAge) //7일 여부 확인
                var totalSize: UInt64 = 0
                var fileInfos: [(url: URL, size: UInt64, date: Date)] = []

                for file in files {
                    guard let resource = try? file.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]) else { continue }

                    let size = UInt64(resource.fileSize ?? 0)
                    let date = resource.contentModificationDate ?? .distantPast

                    // 오래된 파일은 즉시 삭제
                    if date < expirationDate {
                        try? fileManager.removeItem(at: file)
                        continue
                    }

                    totalSize += size
                    fileInfos.append((url: file, size: size, date: date))
                }

                // 용량 초과 시 오래된 순으로 정리
                if totalSize > maxCacheSize {
                    let over = totalSize - maxCacheSize
                    var freed: UInt64 = 0

                    for info in fileInfos.sorted(by: { $0.date < $1.date }) {
                        try? fileManager.removeItem(at: info.url)
                        freed += info.size
                        if freed >= over { break }
                    }
                }

                continuation.resume()
            }
        }
    }

    
}
