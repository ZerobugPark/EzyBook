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
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(APIError(localErrorType: .decodingError))
        }
    }
}

