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
}

