//
//  NetworkService.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

import Alamofire

final class NetworkService {
    
    private init() {}
    
    static let shared = NetworkService()
    
//    func request<T: NetworkRouter>(_ router: T, completion: @escaping (Result<Data, Error>) -> Void) {
//            
//            // Alamofire 요청 보내기
//        AF.request(router.endpoint!,
//                       method: router.method,
//                       parameters: router.parameters,
//                       encoding: JSONEncoding.default,
//                       headers: router.headers)
//                .validate()
//                .responseData { response in
//                    switch response.result {
//                    case .success(let data):
//                        completion(.success(data))  // 요청 성공 시 데이터 반환
//                    case .failure(let error):
//                        completion(.failure(error))  // 오류 발생 시 처리
//                    }
//                }
//        }
    
    func request<T: Decodable ,R: NetworkRouter>(data: T.Type, _ router: R) {
        
        
        do {
            let urlRequest = try router.asURLRequest()

            AF.request(urlRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let data):
                        print("✅ 성공: \(data)")
                    case .failure(let error):
                        print("❌ 실패: \(error)")
                    }
                }
        } catch {
            print("❗️URLRequest 생성 실패: \(error)")
        }
    }
}
