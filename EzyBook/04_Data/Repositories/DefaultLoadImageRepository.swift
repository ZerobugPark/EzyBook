//
//  DefaultLoadImageRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation


final class DefaultLoadImageRepository: LoadOriginalImage, LoadThumbnailImage {
    
    private let imageLoader: ImageLoder
    private let imageCache: ImageCache
    
    init(imageLoader: ImageLoder, imageCache: ImageCache) {
        self.imageLoader = imageLoader
        self.imageCache = imageCache
    }
    
    
    /// 원본 이미지 호출 (디스크 캐시 전용)
    func loadOriginalImage(from path: String) async throws -> UIImage {
        
        let fullURL = APIConstants.baseURL + "/v1" + path
        
        /// 디스크 캐시 확인 (메모리 캐시는 사용하지 않음)
        if let data = imageCache.getData(forKey: fullURL), let image = UIImage(data: data) {
            return image
        }
        
        /// Etag 기반 요청
        let etag = UserDefaultManager.etag[fullURL]
        let response = try await imageLoader.fetchImageData(from: fullURL, etag: etag)
        
        switch response.statusCode {
        case 304:
            if let data = imageCache.getData(forKey: fullURL), let image = UIImage(data: data) {
                 return image
             }
             UserDefaultManager.etag.removeValue(forKey: fullURL)
             return try await reloadOriginalImageWithoutETag(url: fullURL)
            
        case 200:
            if let newETag = response.etag {
                var etags = UserDefaultManager.etag
                etags[fullURL] = newETag
                UserDefaultManager.etag = etags
            }
            
            //압축해서 저장
            if let image = UIImage(data: response.data),
               let compressedData = image.jpegData(compressionQuality: 0.8) {
                imageCache.setData(compressedData, forKey: fullURL) // 디시크 캐시에 저장
                return image
            } else {
                imageCache.setData(response.data, forKey: fullURL) // fallback
                return UIImage(data: response.data) ?? UIImage(systemName: "star")! // 데이터가 이미지로 변환 안되면 기본 이미지 처리
            }
            
            
        default:
            throw APIError(statusCode: response.statusCode, data: response.data)
            
        }
        
    }
    

    
    
    ///쌈네일/미디어 (메모리 + 디스크 캐시)
    func loadMediaPreview(from path: String, scale: CGFloat) async throws -> UIImage {
        
        let fullURL = APIConstants.baseURL + "/v1" + path

        // UTType 기반 분기
        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        if let utType = UTType(filenameExtension: fileExtension) {
            if utType.conforms(to: .movie) {
                return try await loadVideoThumbnail(from: fullURL, scale: scale)
            }
        }

        /// 1.  메모리 캐시 확인
        if let image = imageCache.get(forKey: fullURL) {
            return image
        }

        /// 2. 디스크 캐시 확인 (메모리 비어있을 때만)
        if let data = imageCache.getData(forKey: fullURL) {
            let downsampled = await downsampleImage(data, scale)
            imageCache.set(downsampled, forKey: fullURL)
            return downsampled
        }

        ///3.) 네트워크 요청 (ETag 기반)
        let etag = UserDefaultManager.etag[fullURL]
        let response = try await imageLoader.fetchImageData(from: fullURL, etag: etag)

        switch response.statusCode {
        case 304:
            if let cachedImage = imageCache.get(forKey: fullURL) {
                return cachedImage
            }
            if let data = imageCache.getData(forKey: fullURL) {
                let image = await downsampleImage(data, scale)
                imageCache.set(image, forKey: fullURL)
                return image
            }
            UserDefaultManager.etag.removeValue(forKey: fullURL)
            return try await reloadMediaPreviewWithoutETag(url: fullURL, scale: scale)

        case 200:
            if let newEtag = response.etag {
                var etags = UserDefaultManager.etag
                etags[fullURL] = newEtag
                UserDefaultManager.etag = etags
            }
            
            //압축해서 저장
            if let image = UIImage(data: response.data),
               let compressedData = image.jpegData(compressionQuality: 0.8) {
                imageCache.setData(compressedData, forKey: fullURL) // 디시크 캐시에 저장
            } else {
                imageCache.setData(response.data, forKey: fullURL) // fallback
                
            }

            let image = await downsampleImage(response.data, scale)
            imageCache.set(image, forKey: fullURL)
            
            return image

        default:
            throw APIError(statusCode: response.statusCode, data: response.data)
        }
        

        
    }
    
    

    
    
    
}




// MARK: - Private Helpers
extension DefaultLoadImageRepository {
    
    
    private func loadVideoThumbnail(from url: String, scale: CGFloat) async throws -> UIImage {
        
        let response = try await imageLoader.fetchImageData(from: url, etag: nil)

        switch response.statusCode {
        case 200:
            guard let thumbnail = await generateThumbnail(fromVideoData: response.data, scale: scale) else {
                throw APIError.localError(type: .thumbnailFailed, message: "비디오 썸네일 생성 실패")
            }
            let downsampled = await downsampleImage(thumbnail.jpegData(compressionQuality: 1.0) ?? Data(), scale)
            return downsampled

        default:
            throw APIError(statusCode: response.statusCode, data: response.data)
        }
    }

    private func generateThumbnail(fromVideoData data: Data, scale: CGFloat) async -> UIImage? {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        do {
            try data.write(to: tempURL)
            let asset = AVAsset(url: tempURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 512 * scale, height: 512 * scale)

            let time = CMTime(seconds: 0.5, preferredTimescale: 600)
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
    
        /// 304: 이미지 변경 없음
        /// 304이긴 하나, 메모리 및 디스크 캐시에 이미지가 없을 때 (메모리나, 디스크가 삭제 되었을 때)
        private func reloadOriginalImageWithoutETag(url: String) async throws -> UIImage {
            let response = try await imageLoader.fetchImageData(from: url, etag: nil)
            if let newEtag = response.etag {
                var etags = UserDefaultManager.etag
                etags[url] = newEtag
                UserDefaultManager.etag = etags
            }
            
            //압축해서 저장
            if let image = UIImage(data: response.data),
               let compressedData = image.jpegData(compressionQuality: 0.8) {
                imageCache.setData(compressedData, forKey: url) // 디시크 캐시에 저장
                return image
            } else {
                imageCache.setData(response.data, forKey: url) // fallback
                return UIImage(data: response.data) ?? UIImage(systemName: "star")! // 데이터가 이미지로 변환 안되면 기본 이미지 처리
            }
            
        }

        private func reloadMediaPreviewWithoutETag(url: String, scale: CGFloat) async throws -> UIImage {
            let response = try await imageLoader.fetchImageData(from: url, etag: nil)
            if let newEtag = response.etag {
                var etags = UserDefaultManager.etag
                etags[url] = newEtag
                UserDefaultManager.etag = etags
            }
            
            //압축해서 저장
            if let image = UIImage(data: response.data),
               let compressedData = image.jpegData(compressionQuality: 0.8) {
                imageCache.setData(compressedData, forKey: url) // 디시크 캐시에 저장
            } else {
                imageCache.setData(response.data, forKey: url) // fallback
                
            }

            let image = await downsampleImage(response.data, scale)
            imageCache.set(image, forKey: url)
            
            return image


        }

    ///Create a smaller version of the full image, optimized for quick display or preview
    /// 다운샘플링된 이미지 == “썸네일”
    /// 단지 작게 보이느냐가 아니라, 메모리 효율을 위해 줄였느냐가 핵심
    ///  UIScreen.main.scale 추후 없어질 수도 있어서 @Environment(\.displayScale) 주입으로 바꾸는게 좋을 듯
    ///  Uikit: view?.window?.windowScene?.screen.scale
        private func downsampleImage(_ data: Data, _ scale: CGFloat) async -> UIImage {
            downsample(imageData: data, to: CGSize(width: 100, height: 100), scale: scale)
            ?? UIImage(systemName: "star")!
        }

        private func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
            /// 원본 이미지를 메모리에 즉시 디코딩하지 않도록 설정
            /// Dirty Memory 방지
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
         
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return nil }

            let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
            
            /// kCGImageSourceCreateThumbnailFromImageAlways: 원본 크기와 상관없이 썸네일 생성
            /// kCGImageSourceShouldCacheImmediately: 썸네일 생성 즉시 디코딩 및 메모리에 로딩
            /// kCGImageSourceCreateThumbnailWithTransform: EXIF 회전 정보 적용
            /// kCGImageSourceThumbnailMaxPixelSize: 썸네일의 최대 크기
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary

            /// 썸네일 생성
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
}

