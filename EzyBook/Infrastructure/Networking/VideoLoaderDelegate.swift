//
//  VideoLoaderDelegate.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import Foundation
import AVFoundation
import Alamofire

class VideoLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    
    var path: String?
    private let tokenService: TokenLoadable
    private let interceptor: TokenInterceptor?
    
    init(tokenService: TokenLoadable, interceptor: TokenInterceptor?) {
        self.tokenService = tokenService
        self.interceptor = interceptor
    }

    /// loader는 파라미터만 받고 별다른 동작은 하지 않음
    /// DRM, 미디어 키 인증 같은 고급 작업을 한다면 필요할 수도
    func resourceLoader(_ loader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource request: AVAssetResourceLoadingRequest) -> Bool {
        print("✅ resoruceLoader 실행")
        guard let path = path else {
            request.finishLoading(with: NSError(domain: "Missing path", code: -1))
            return false // path가 없어서, 요청을 받아드릴 수 없는 상황
        }

        Task {
            do {
                let data = try await downloadVideoData(path)
                
                // ✅ 메타 정보 제공
                if let contentInformation = request.contentInformationRequest {
                    /// 비디오 포맷
                    contentInformation.contentType = AVFileType.mp4.rawValue
                    
                    /// 추후 패스에 따라서 구분해야할 수도 있음
//                    if path.hasSuffix(".mov") {
//                        contentInformation.contentType = AVFileType.mov.rawValue
//                    } else if path.hasSuffix(".m4v") {
//                        contentInformation.contentType = AVFileType.m4v.rawValue
//                    }
                    
                    /// 전체 데이터 크기
                    contentInformation.contentLength = Int64(data.count)
                    /// 범위기반 요청이 가능한지
                    contentInformation.isByteRangeAccessSupported = true
                }

                if let dataRequest = request.dataRequest {
                    /// AvPlayer가 요청한  데이터 범위
                    let offset = Int(dataRequest.requestedOffset)
                    let length = dataRequest.requestedLength
                    
                    /// 해당 범위만큼 잘라서 응답
                    let rangeEnd = min(offset + length, data.count)
                    let subdata = data.subdata(in: offset..<rangeEnd)
                    

                    /// Player에게 전달
                    dataRequest.respond(with: subdata)
                }
                
                request.finishLoading()
            } catch {
                request.finishLoading(with: error)
            }
        }

        ///  True: 테스크 내부에서 데이터를 나중에 줄 테니까 AVFoudation 한테 기다려 요청
        ///  false:일 경우 delegate가 요청 거부
        return true
    }

    private func downloadVideoData(_ path: String) async throws -> Data {
        let fullURL = APIConstants.baseURL + "/v1" + path
        print(fullURL)
        
        guard let token = tokenService.accessToken else {
            throw APIError.localError(type: .tokenNotFound, message: nil)
        }
        
        let header: HTTPHeaders = [
            "SeSACKey" : APIConstants.apiKey,
            "Authorization" : token
        ]

        let response = await AF.request(fullURL, headers: header, interceptor: interceptor)
            .validate(statusCode: 200...304)
            .serializingData()
            .response
        

        switch response.result {
        case.success(let data):
            return data
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
}

