//
//  DefaultNetworkService.swift
//  EzyBook
//
//  Created by youngkyun park on 5/13/25.
//

import Foundation
import Alamofire

final class DefaultNetworkService: NetworkService {

    private let decodingService: ResponseDecoder
    private let interceptor: TokenInterceptor? // 이것도 추상화를 해줘야하나
    private let session: Session
    
    init(decodingService: ResponseDecoder, interceptor: TokenInterceptor?) {
        self.decodingService = decodingService
        self.interceptor = interceptor
        self.session = interceptor != nil ? Session(interceptor: interceptor) : AF
    }
    
    func fetchData<T: Decodable & EntityConvertible, R: NetworkRouter>(dto: T.Type ,_ router: R) async throws -> T {
        
        let urlRequest: URLRequest
        do {
            urlRequest = try router.asURLRequest()
        } catch {
            throw APIError(localErrorType: .missingEndpoint)
        }
    
        let response = await session.request(urlRequest)
            .validate(statusCode: 200...299)
            .serializingData()
            .response
        
        if let request = response.request {
            print("Full URL:", request.url?.absoluteString ?? "nil")
            print("Full URL:", urlRequest)
            print("HTTP Method:", request.httpMethod ?? "nil")
            print("Headers:", request.headers)
        }
        
        #if DEBUG
        let urlString = urlRequest.url?.absoluteString ?? "Invalid URL"
        #endif
        
        let statusCode = response.response?.statusCode
        
        switch response.result {
        case .success(let data):
            
            let decodedResult = decodingService.decode(data: data, type: dto)
            
            #if DEBUG
            NetworkLog.success(url: urlString, statusCode: statusCode ?? 0, data: data)
            #endif
           
            switch decodedResult {
            case .success(let decodedDTO):
                return decodedDTO
            case .failure(let decodeError):
                throw decodeError
            }
        case .failure(let afError):
            #if DEBUG
            NetworkLog.failure(url: urlString, statusCode: statusCode ?? 0, data: response.data)
            #endif
            
            let responseData = response.data
            if let code = statusCode {
                throw APIError(statusCode: code, data: responseData)
            } else {
                let errorCode = (afError as NSError).code
                throw APIError(statusCode: errorCode, data: responseData)
            }
        }
    }
    
}


