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


final class DefaultImageLoader: ImagerLoader {
    
    private let tokenService: TokenLoadable
    private let imageCache: ImageMemoryCache
    private let interceptor: TokenInterceptor?
    
    init(tokenService: TokenLoadable, imageCache: ImageMemoryCache, interceptor: TokenInterceptor?) {
        self.tokenService = tokenService
        self.imageCache = imageCache
        self.interceptor = interceptor
    }
    
    
    func loadMediaPreview(from path: String, scale: CGFloat) async throws -> UIImage {
        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()

        if let utType = UTType(filenameExtension: fileExtension) {
            if utType.conforms(to: .image) {
                return try await loadImage(from: path, scale: scale)
            } else if utType.conforms(to: .movie) {
                return try await loadVideoThumbnail(from: path, scale: scale)
            }
        }

        throw APIError.localError(type: .invalidMediaType, message: nil)
    }
    
    private func loadImage(from path: String, scale: CGFloat) async throws ->  UIImage {
        
        
        let fullURL = APIConstants.baseURL + "/v1" + path
        
        /// 캐시에 데이터 여부 판단
//        if let cached = imageCache.get(forKey: fullURL) {
//            return cached
//        }
        
        
        guard let token = tokenService.accessToken else {
            throw APIError.localError(type: .tokenNotFound, message: nil)
        }
        
        let header: HTTPHeaders = [
            "SeSACKey" : APIConstants.apiKey,
            "Authorization" : token
        ]
        
//        let header: HTTPHeaders = [
//            "SeSACKey" : APIConstants.apiKey,
//            "Authorization" : token,
//            "If-None-Match" : etag
//        ]
        
        let response = await AF.request(fullURL, headers: header, interceptor: interceptor)
            .validate(statusCode: 200...304)
            .serializingData()
            .response
        
        
#if DEBUG
//        if let request = response.request {
//            print("Full URL:", request.url?.absoluteString ?? "nil")
//            print("HTTP Method:", request.httpMethod ?? "nil")
//            print("Headers:", request.headers)
//        }
        //TODO: etag랑 캐시정책 고려해보기
        let etag = response.response?.allHeaderFields["Etag"] as? String
        //print(etag)
        
        //print(response.response?.statusCode)
#endif
        
        switch response.result {
        case.success(let data):
            printDataSize(data)
            //imageCache.set(data, forKey: fullURL)
            let image = await loadAndDownsampleImage(data, scale)
            return image
        case .failure(let failure):
            let responseData = response.data
            let statusCode = response.response?.statusCode
            if let code = statusCode {
                throw APIError(statusCode: code, data: responseData)
            } else {
                let errorCode = (failure as NSError).code
                throw APIError(statusCode: errorCode, data: responseData)
            }
            
        }
        
        
    }
    
    private func loadVideoThumbnail(from path: String, scale: CGFloat) async throws -> UIImage {
        let fullURL = APIConstants.baseURL + "/v1" + path

        guard let token = tokenService.accessToken else {
            throw APIError.localError(type: .tokenNotFound, message: nil)
        }

        let header: HTTPHeaders = [
            "SeSACKey": APIConstants.apiKey,
            "Authorization": token
        ]

        let response = await AF.request(fullURL, headers: header, interceptor: interceptor)
            .validate(statusCode: 200...304)
            .serializingData()
            .response

        switch response.result {
        case .success(let data):
            printDataSize(data)
            guard let thumbnail = await generateThumbnail(fromVideoData: data, scale: scale) else {
                throw APIError.localError(type: .thumbnailFailed, message: "비디오 썸네일 생성 실패")
            }
            let downsampled = await loadAndDownsampleImage(thumbnail.jpegData(compressionQuality: 1.0) ?? Data(), scale)
            return downsampled

        case .failure(let failure):
            let responseData = response.data
            let statusCode = response.response?.statusCode
            if let code = statusCode {
                throw APIError(statusCode: code, data: responseData)
            } else {
                let errorCode = (failure as NSError).code
                throw APIError(statusCode: errorCode, data: responseData)
            }
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
            print("썸네일 생성 실패: \(error.localizedDescription)")
            return nil
        }
    }

    
}

extension DefaultImageLoader {
    private func printDataSize(_ data: Data) {
        let bytes = data.count
        let kb = Double(bytes) / 1024
        let mb = kb / 1024

        //print(String(format: "📦 Data size: %.2f MB (%.0f KB / %d bytes)", mb, kb, bytes))
    }
}


extension DefaultImageLoader {
    
    
    private func loadAndDownsampleImage(_ data: Data, _ scale: CGFloat) async -> UIImage {
            /// 우선순위
            /// utility:  데이터처리, 이미지 디코딩
            /// 메인쓰레드가 혹시나 디코딩 작업을 할 수도 있기 때문에, 성능 차원에서 백그라운드 쓰레드로 전환
            let downSamplingImage = await Task(priority: .utility) {
                return downsample(imageData: data, to: CGSize(width: 100, height: 100), scale: scale)
            }.value

            guard let image = downSamplingImage else {
                let fallback = UIImage(systemName: "star")!
                return fallback
            }
        
            return image
        }
    
    
    ///Create a smaller version of the full image, optimized for quick display or preview
    /// 다운샘플링된 이미지 == “썸네일”
    /// 단지 작게 보이느냐가 아니라, 메모리 효율을 위해 줄였느냐가 핵심
    ///  UIScreen.main.scale 추후 없어질 수도 있어서 @Environment(\.displayScale) 주입으로 바꾸는게 좋을 듯
    ///  Uikit: view?.window?.windowScene?.screen.scale
    private func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        
        
        /// 원본 이미지를 메모리에 즉시 디코딩하지 않도록 설정
        /// Dirty Memory 방지
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        /// Core Graphics의 이미지 소스 생성
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)!
        
        
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

