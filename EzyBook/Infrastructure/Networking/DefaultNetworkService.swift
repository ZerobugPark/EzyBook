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
    
    init(decodingService: ResponseDecoder) {
        self.decodingService = decodingService
    }
    
    func fetchData<T: Decodable & EntityConvertible, R: NetworkRouter>(dto: T.Type ,_ router: R) async throws -> T {
        
        let urlRequest: URLRequest
        do {
            urlRequest = try router.asURLRequest()
        } catch {
            throw APIError(localErrorType: .missingEndpoint)
        }
        
        
        let response = await AF.request(urlRequest)
            .validate(statusCode: 200...299)
            .serializingData()
            .response
        switch response.result {
        case .success(let data):
            let decodedResult = decodingService.decode(data: data, type: dto)
            switch decodedResult {
            case .success(let decodedDTO):
                return decodedDTO
            case .failure(let decodeError):
                throw decodeError
            }
        case .failure(let afError):
            let statusCode = response.response?.statusCode
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


