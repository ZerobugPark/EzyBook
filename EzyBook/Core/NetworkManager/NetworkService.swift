//
//  NetworkService.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

import Alamofire

final class NetworkService: NetworkManager {
    
    
    func request<R: NetworkRouter>(_ router: R, completionHandler: @escaping (Result <Data, APIError>) -> Void) {
        
        do {
            let urlRequest = try router.asURLRequest()
            print(urlRequest)
            AF.request(urlRequest)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        completionHandler(.success(data))
                    case .failure(let error):
                        let responseMessage = response.data
                        if let statusCode = response.response?.statusCode {
                            let error = APIError(statusCode: statusCode, data: responseMessage)
                            completionHandler(.failure(error))
                        } else {
                            let errorCode = (error as NSError).code
                            let error = APIError(statusCode: errorCode, data: responseMessage)
                            completionHandler(.failure(error))
                        }
                    }
                }
        } catch {
            let error = APIError(localErrorType: .missingEndpoint)
            completionHandler(.failure(error))
        }
        
        
    }
    
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

