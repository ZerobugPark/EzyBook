//
//  TokenUseCases.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

/// callAsFunction:  객체를 함수처럼 쓸 수 있게 해줌
/// let result = saveTokenUseCase(key: key, value: value)
/// let result = saveTokenUseCase.callAsFunction(key: key, value: value)
protocol SaveTokenUseCase {
    
    func callAsFunction(key: String, value: String) -> Bool
}

protocol LoadTokenUseCase {
    func callAsFunction(key: String) -> String?
}


protocol DeleteTokenUseCase {
    func callAsFunction(key: String) -> Bool
}
