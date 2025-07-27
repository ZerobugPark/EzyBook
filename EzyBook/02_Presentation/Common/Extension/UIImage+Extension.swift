//
//  UIImage+Extension.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import SwiftUI

extension UIImage {
    
    func resized(to maxDimension: CGFloat) -> UIImage? {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }
        
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func compressedJPEGData(maxSizeInBytes: Int = 1_000_000, maxDimension: CGFloat = 1200) -> Data? {
        guard let resized = self.resized(to: maxDimension) else { return nil }

        if let bestQualityData = resized.jpegData(compressionQuality: 1.0),
           bestQualityData.count <= maxSizeInBytes {
            return bestQualityData
        }
        
        // 용량이 넘으면 압축 시작
        var compression: CGFloat = 0.9
        let minCompression: CGFloat = 0.1
        var compressedData: Data? = nil
        
        while compression >= minCompression {
            if let data = resized.jpegData(compressionQuality: compression),
               data.count <= maxSizeInBytes {
                compressedData = data
                break
            }
            compression -= 0.1
        }
        
        return compressedData
        
        
    }
}
