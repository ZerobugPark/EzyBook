//
//  NetworkRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/13/25.
//

import Foundation

final class NetworkRepository: EzyBookNetworkRepository {
    
    private let networkManger: NetworkManager
    private let decodingManager: ResponseDecoder
    
    init(networkManger: NetworkManager, decodingManager: ResponseDecoder) {
        self.networkManger = networkManger
        self.decodingManager = decodingManager
    }
    
    func fetchData<T: Decodable, R: NetworkRouter>(_ router: R, completionHandler: @escaping (Result<T, APIErrorResponse>) -> Void) {
        
        networkManger.request(router) { (result: Result<Data, APIError>) in
                        
            switch result {
            case .success(let data):
                let decodedResult = self.decodingManager.decode(data: data, type: JoinResponseDTO.self)
                
                switch decodedResult {
                case .success(let success):
                    completionHandler(.success(success as! T))
                case .failure:
                    let responseCode = APIError(statusCode: 10002)
                    let error = APIErrorResponse.api(responseCode.rawValue, message: responseCode.defaultMessage)
                    completionHandler(.failure(error))
                }
                
            case .failure(let failure):
                let error = APIErrorResponse.api(failure.rawValue, message: failure.defaultMessage)
                completionHandler(.failure(error))
            }
        }
    }
    
    
    
}
    
   
    

