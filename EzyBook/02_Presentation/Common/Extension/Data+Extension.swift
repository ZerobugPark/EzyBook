//
//  Data+Extension.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import AVKit


///  Video (AVAsset)은 반드시 파일 기반으로 처리해야 함
///  AVAsset 및 AVAssetExportSession은 URL 기반으로 동작
///  즉, 메모리(Data)만 가지고는 압축 불가능

/// 그래서 필요한 흐름:
/// 1. Data → 임시 파일로 저장 (FileManager)
/// 2. AVAsset(url:) 로 asset 생성
/// 3. AVAssetExportSession 으로 압축 또는 해상도 변경
/// 4. 출력 파일을 다시 Data로 읽음
/// 5. 임시 파일들 삭제
extension Data {
    func downsized(toMaxSize maxSizeInBytes: Int) async -> Data? {
        guard self.count > maxSizeInBytes else { return self }

        let presets: [String] = [
            AVAssetExportPreset1280x720,
            AVAssetExportPreset960x540,
            AVAssetExportPreset640x480
        ]

        for preset in presets {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
            do {
                try self.write(to: tempURL)
                let asset = AVAsset(url: tempURL)
                guard let exporter = AVAssetExportSession(asset: asset, presetName: preset) else { continue }

                let exportURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "_exported.mp4")
                exporter.outputURL = exportURL
                exporter.outputFileType = .mp4
                exporter.shouldOptimizeForNetworkUse = true

                try await withCheckedThrowingContinuation { continuation in
                    exporter.exportAsynchronously {
                        continuation.resume()
                    }
                }

                if let compressedData = try? Data(contentsOf: exportURL),
                   compressedData.count <= maxSizeInBytes {
                    try? FileManager.default.removeItem(at: tempURL)
                    try? FileManager.default.removeItem(at: exportURL)
                    return compressedData
                }

                // Clean up if size too large or read fails
                try? FileManager.default.removeItem(at: tempURL)
                try? FileManager.default.removeItem(at: exportURL)

            } catch {
                continue
            }
        }

        return nil
    }
}
