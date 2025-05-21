//
//  DefaultHttpClient.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation
import Alamofire

final class DefaultHttpClient: HttpClient {
    
    func request<R: NetworkRouter>(_ router: R) async throws -> Data {
        
        let urlRequest: URLRequest
        do {
            urlRequest = try router.asURLRequest()
        } catch {
            throw APIError(localErrorType: .missingEndpoint)
        }
        
        //Alamofire에서 Combine이나 async/await을 위해 제공하는 구조
        let response = await AF.request(urlRequest)
            .serializingData()
            .response
        
        switch response.result {
        case .success(let data):
            return data
        case .failure(let afError):
            let statusCode = response.response?.statusCode
            let responseData = response.data //에러메시지
            if let code = statusCode {
                throw APIError(statusCode: code, data: responseData)
            } else {
                let errorCode = (afError as NSError).code
                throw APIError(statusCode: errorCode, data: responseData)
            }
        }
    }
}

