//
//  ResponseDecoder.swift
//  EzyBook
//
//  Created by youngkyun park on 5/13/25.
//

import Foundation

/// 네트워크 응답 디코더 구현
struct ResponseDecoder {
    func decode<T: Decodable>(data: Data, type: T.Type) -> Result<T, APIError> {
        do {
            /// 나중에 테스트 해볼 것
            //let test = JSONDecoder()
            //test.keyDecodingStrategy = .convertFromSnakeCase
            // let decoded = try JSONDecoder().decode(T.self, from: data)
            //decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(APIError(localErrorType: .decodingError))
        }
    }
}

