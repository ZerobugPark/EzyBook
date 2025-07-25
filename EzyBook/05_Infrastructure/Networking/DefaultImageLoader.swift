//
//  DefaultImageLoader.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import SwiftUI
import Alamofire
import AVFoundation
import UniformTypeIdentifiers

/// Infra 계층: 순수 IO (네트워크 + 디스크 접근만 담당)
struct ImageResponse {
    let data: Data
    let statusCode: Int
    let etag: String?
}


final class DefaultImageLoader: ImageLoder {
    
    private let tokenService: TokenLoadable
    private let interceptor: TokenInterceptor
    private let session: Session
    
    init(tokenService: TokenLoadable, interceptor: TokenInterceptor) {
        self.tokenService = tokenService
        self.interceptor = interceptor
        self.session = Session(interceptor: interceptor)
    }
    
    
    func fetchImageData(from url: String, etag: String?) async throws -> ImageResponse {
        
        guard let token = tokenService.accessToken else {
            throw APIError.localError(type: .tokenNotFound, message: nil)
        }
        
        var header: HTTPHeaders = [
                 "SeSACKey": APIConstants.apiKey,
                 "Authorization": token
             ]
        
        /// etag 추가
        if let etag = etag {
            header.add(name: "If-None-Match", value: etag)
        }
        
        let response = await session.request(url, headers: header)
            .validate(statusCode: 200...304)
            .serializingData()
            .response
        
        let statusCode = response.response?.statusCode ?? -1
        let etagFromHeader = response.response?.allHeaderFields["Etag"] as? String
        
        switch response.result {
           case .success(let data):
               return ImageResponse(data: data, statusCode: statusCode, etag: etagFromHeader)
           case .failure:
               throw APIError(statusCode: statusCode, data: response.data)
           }
        
        
    }
    
//    
//    /// 썸네일 및 비디오 이미지 로드
//    func loadMediaPreview(from path: String, scale: CGFloat) async throws -> UIImage {
//        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
//
//        if let utType = UTType(filenameExtension: fileExtension) {
//            if utType.conforms(to: .image) {
//                return try await loadImage(from: path, scale: scale)
//            } else if utType.conforms(to: .movie) {
//                return try await loadVideoThumbnail(from: path, scale: scale)
//            }
//        }
//
//        throw APIError.localError(type: .invalidMediaType, message: nil)
//    }
//    
//    /// 원본 이미지 로드 (확대)
//    func loadOriginalImage(from path: String) async throws -> UIImage {
//        let fullURL = APIConstants.baseURL + "/v1" + path
//        
//        if let data = imageCache.getData(forKey: fullURL), let image = UIImage(data: data) {
//            return image
//        }
//        
//        guard let token = tokenService.accessToken else {
//            throw APIError.localError(type: .tokenNotFound, message: nil)
//        }
//        
//        let header: HTTPHeaders = [
//            "SeSACKey" : APIConstants.apiKey,
//            "Authorization" : token
//        ]
//
//        let response = await session.request(fullURL, headers: header)
//            .validate(statusCode: 200...304)
//            .serializingData()
//            .response
//
//        
//        switch response.result {
//        case.success(let data):
//            imageCache.setData(data, forKey: fullURL)
//            return UIImage(data: data) ?? UIImage(systemName: "star")!
//        case .failure(_):
//            let code = response.response?.statusCode ?? -1
//            throw APIError(statusCode: code, data: response.data)
//        }
//    }
//
//
//
//
//
//    private func loadImage(from path: String, scale: CGFloat) async throws ->  UIImage {
//        
//        let fullURL = APIConstants.baseURL + "/v1" + path
//            
//        guard let token = tokenService.accessToken else {
//            throw APIError.localError(type: .tokenNotFound, message: nil)
//        }
//        
//        var header: HTTPHeaders = [
//            "SeSACKey" : APIConstants.apiKey,
//            "Authorization" : token
//        ]
//        
//        /// etag 추가
//        if let etag = UserDefaultManager.etag[fullURL] {
//            header.add(name: "If-None-Match", value: etag)
//        }
//        
//        let response = await session.request(fullURL, headers: header)
//            .validate(statusCode: 200...304)
//            .serializingData()
//            .response
//        
//        
//        let statusCode = response.response?.statusCode ?? -1
//        let etagFromHeader = response.response?.allHeaderFields["Etag"] as? String
//
//
//        
//        
//        if let request = response.request {
//            print("Full URL:", request.url?.absoluteString ?? "nil")
//            print("HTTP Method:", request.httpMethod ?? "nil")
//            print("Headers:", request.headers)
//        }
//    
//        if statusCode == 444 {
//            print("here")
//        }
//    
//        //// 리소스 데이터가 없으면 실패로 처리하넹
//        switch statusCode {
//        case 304:
//            if let image = imageCache.get(forKey: fullURL) {
//                return image
//            }
//            if let data = imageCache.getData(forKey: fullURL) {
//                let image = await loadAndDownsampleImage(data, scale)
//                imageCache.set(image, forKey: fullURL)
//                return image
//            }
//            // 캐시 불일치
//            UserDefaultManager.etag.removeValue(forKey: fullURL)
//            return try await reloadImageWithoutETag(url: fullURL, scale: scale, token: token)
//
//        case 200:
//            if let newETag = etagFromHeader {
//                var etags = UserDefaultManager.etag
//                etags[fullURL] = newETag
//                UserDefaultManager.etag = etags
//            }
//
//            switch response.result {
//            case .success(let data):
//                imageCache.setData(data, forKey: fullURL)
//                let image = await loadAndDownsampleImage(data, scale)
//                imageCache.set(image, forKey: fullURL)
//                return image
//
//            case .failure:
//                throw APIError(statusCode: statusCode, data: response.data)
//            }
//
//        default:
//            throw APIError(statusCode: statusCode, data: response.data)
//        }
//
//        
//    }
//    
//    private func loadVideoThumbnail(from path: String, scale: CGFloat) async throws -> UIImage {
//        let fullURL = APIConstants.baseURL + "/v1" + path
//
//        guard let token = tokenService.accessToken else {
//            throw APIError.localError(type: .tokenNotFound, message: nil)
//        }
//
//        let header: HTTPHeaders = [
//            "SeSACKey": APIConstants.apiKey,
//            "Authorization": token
//        ]
//
//        let response = await session.request(fullURL, headers: header)
//            .validate(statusCode: 200...304)
//            .serializingData()
//            .response
//
//        
//
//        switch response.result {
//        case .success(let data):
//            guard let thumbnail = await generateThumbnail(fromVideoData: data, scale: scale) else {
//                throw APIError.localError(type: .thumbnailFailed, message: "비디오 썸네일 생성 실패")
//            }
//            let downsampled = await loadAndDownsampleImage(thumbnail.jpegData(compressionQuality: 1.0) ?? Data(), scale)
//            return downsampled
//
//        case .failure(_):
//            let code = response.response?.statusCode ?? -1
//            throw APIError(statusCode: code, data: response.data)
//        }
//    }
//    
//    private func generateThumbnail(fromVideoData data: Data, scale: CGFloat) async -> UIImage? {
//        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
//            .appendingPathComponent(UUID().uuidString)
//            .appendingPathExtension("mp4")
//
//        do {
//            try data.write(to: tempURL)
//
//            let asset = AVAsset(url: tempURL)
//            let generator = AVAssetImageGenerator(asset: asset)
//            generator.appliesPreferredTrackTransform = true
//            generator.maximumSize = CGSize(width: 512 * scale, height: 512 * scale)
//
//            let time = CMTime(seconds: 0.5, preferredTimescale: 600)
//            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
//            return UIImage(cgImage: cgImage)
//        } catch {
//            return nil
//       
//        }
//    }

    
}

extension DefaultImageLoader {
    private func printDataSize(_ data: Data) {
        let bytes = data.count
        let kb = Double(bytes) / 1024
        let mb = kb / 1024
        print(String(format: "📦 Data size: %.2f MB (%.0f KB / %d bytes)", mb, kb, bytes))
    }
}



//extension DefaultImageLoader {
//
//    /// 304일 때, retry 함수
//    private func reloadImageWithoutETag(url: String, scale: CGFloat, token: String) async throws -> UIImage {
//
//        let header: HTTPHeaders = [
//            "SeSACKey": APIConstants.apiKey,
//            "Authorization": token
//        ]
//
//        let response = await session.request(url, headers: header)
//            .validate(statusCode: 200...304)
//            .serializingData()
//            .response
//
//        switch response.result {
//        case.success(let data):
//
//            if let newETag = response.response?.allHeaderFields["Etag"] as? String {
//                var etags = UserDefaultManager.etag
//                etags[url] = newETag
//                UserDefaultManager.etag = etags
//            }
//
//            imageCache.setData(data, forKey: url)
//            let image = await loadAndDownsampleImage(data, scale)
//
//            imageCache.set(image, forKey: url)
//            return image
//        case .failure(_):
//            let code = response.response?.statusCode ?? -1
//            throw APIError(statusCode: code, data: response.data)
//        }
//
//    }
//
//
//    private func loadAndDownsampleImage(_ data: Data, _ scale: CGFloat) async -> UIImage {
//        downsample(imageData: data, to: CGSize(width: 100, height: 100), scale: scale) ?? UIImage(systemName: "star")!
//    }
//
//
//    private func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
//
//
//        /// 원본 이미지를 메모리에 즉시 디코딩하지 않도록 설정
//        /// Dirty Memory 방지
//        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//
//        /// Core Graphics의 이미지 소스 생성
//        let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)!
//
//
//        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
//
//        /// kCGImageSourceCreateThumbnailFromImageAlways: 원본 크기와 상관없이 썸네일 생성
//        /// kCGImageSourceShouldCacheImmediately: 썸네일 생성 즉시 디코딩 및 메모리에 로딩
//        /// kCGImageSourceCreateThumbnailWithTransform: EXIF 회전 정보 적용
//        /// kCGImageSourceThumbnailMaxPixelSize: 썸네일의 최대 크기
//        let downsampleOptions = [
//            kCGImageSourceCreateThumbnailFromImageAlways: true,
//            kCGImageSourceShouldCacheImmediately: true,
//            kCGImageSourceCreateThumbnailWithTransform: true,
//            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
//        ] as CFDictionary
//
//        /// 썸네일 생성
//        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
//            return nil
//        }
//
//        return UIImage(cgImage: cgImage)
//    }
//
//}
