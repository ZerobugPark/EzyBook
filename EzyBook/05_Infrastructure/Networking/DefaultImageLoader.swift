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


final class DefaultImageLoader: ImageLoader {
    
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
        
        /// 200: 성공
        /// 204: 성공했지만 응답 본문 X
        /// 205: 성공했지만 본문 없음
        /// 304: 리소스 변경 X (ETga
        let response = await session.request(url, headers: header)
            .validate(statusCode: 200...304)
            .serializingData(emptyResponseCodes: [200, 204, 205, 304])
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
    
}

