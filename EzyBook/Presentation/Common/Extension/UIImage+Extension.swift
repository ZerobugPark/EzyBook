//
//  UIImage+Extension.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import SwiftUI

extension UIImage {
    func compressedJPEGData(maxSizeInBytes: Int = 1_000_000) -> Data? {
        var compression: CGFloat = 0.8
        let minCompression: CGFloat = 0.1
        guard var data = self.jpegData(compressionQuality: compression) else {
            return nil
        }

        while data.count > maxSizeInBytes && compression > minCompression {
            compression -= 0.1
            guard let compressedData = self.jpegData(compressionQuality: compression) else {
                break
            }
            data = compressedData
        }

        return data.count <= maxSizeInBytes ? data : nil
    }
}
