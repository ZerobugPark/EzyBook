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
            
            AF.request(urlRequest)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        completionHandler(.success(data))
                    case .failure:
                        if let statusCode = response.response?.statusCode {
                            let apiError = APIError(statusCode: statusCode)
                            completionHandler(.failure(apiError))
                        } else {
                            // 상태코드가 없을 때
                            completionHandler(.failure(.unknown))
                        }
                    }
                }
        } catch {
            completionHandler(.failure(.missingEndpoint))
        }
        
        
    }
}
