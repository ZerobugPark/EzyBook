//
//  DefaultImageLoader.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import Foundation
import Alamofire


final class DefaultImageLoader: ImagerLoader {
    
    let tokenService: TokenLoadable
    
    init(tokenService: TokenLoadable) {
        self.tokenService = tokenService
    }
    

    
    func loadImage(from path: String) async throws ->  Data? {
        
        guard let token = tokenService.accessToken else {
            throw APIError.localError(type: .tokenNotFound, message: nil)
        }
        
        let fullURL = APIConstants.baseURL + "/v1" + path
        print(fullURL)
        let header: HTTPHeaders = [
            "SeSACKey" : APIConstants.apiKey,
            "Authorization" : token
        ]
        
        let response = await AF.request(fullURL, headers: header)
            .validate(statusCode: 200...299)
            .serializingData()
            .response
        
        
        if let request = response.request {
            print("✅ Full URL:", request.url?.absoluteString ?? "nil")
            print("✅ HTTP Method:", request.httpMethod ?? "nil")
            print("✅ Headers:", request.headers)
        }
        
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
