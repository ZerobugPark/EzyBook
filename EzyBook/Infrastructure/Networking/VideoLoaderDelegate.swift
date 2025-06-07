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
    
    var path: String? // ✅ 나중에 주입
    private let tokenService: TokenLoadable
    private let interceptor: TokenInterceptor?
    
    init(tokenService: TokenLoadable, interceptor: TokenInterceptor?) {
        self.tokenService = tokenService
        self.interceptor = interceptor
    }

    func resourceLoader(_ loader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource request: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let path = path else {
            request.finishLoading(with: NSError(domain: "Missing path", code: -1))
            return false
        }

        Task {
            do {
                let data = try await downloadVideoData(path)
                
                // ✅ 메타 정보 제공
                if let contentInformation = request.contentInformationRequest {
                    contentInformation.contentType = AVFileType.mp4.rawValue
                    contentInformation.contentLength = Int64(data.count)
                    contentInformation.isByteRangeAccessSupported = true
                }

                if let dataRequest = request.dataRequest {
                    let offset = Int(dataRequest.requestedOffset)
                    let length = dataRequest.requestedLength

                    let rangeEnd = min(offset + length, data.count)
                    let subdata = data.subdata(in: offset..<rangeEnd)

                    dataRequest.respond(with: subdata)
                }
                
                
                request.finishLoading()
                print("✅ Success: Data loaded")
            } catch {
                print("❌ Error loading video:", error)
                request.finishLoading(with: error)
            }
        }

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
            dump(data)
            return data
        case .failure(let failure):
            let responseData = response.data
            let statusCode = response.response?.statusCode
            if let code = statusCode {
                print("error",statusCode)
                throw APIError(statusCode: code, data: responseData)
            } else {
                let errorCode = (failure as NSError).code
                print("error",errorCode)
                throw APIError(statusCode: errorCode, data: responseData)
            }
            
        }
    }
}

