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
    
    func fetchData<T: Decodable & EntityConvertible, E: StructEntity, R: NetworkRouter>(dto: T.Type ,_ router: R, completionHandler: @escaping (Result<E, APIError>) -> Void) where T.E == E {
        
        networkManger.request(router) { (result: Result<Data, APIError>) in
                        
            switch result {
            case .success(let data):
                let decodedResult = self.decodingManager.decode(data: data, type: T.self)
                
                switch decodedResult {
                case .success(let success):
                    let entity = success.toEntity()
                    completionHandler(.success(entity))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
}
    
  
