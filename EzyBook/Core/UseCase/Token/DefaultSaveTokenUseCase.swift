//
//  DefaultSaveTokenUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

/// 의도(Intent) 기반으로 나누는 것이 UseCase의 핵심
/// 얼마나 나눠야 하지? 모든 기능을 다 나누면 너무 파일이 많아지는데..
final class DefaultSaveTokenUseCase: SaveTokenUseCase {
    private let tokenRepository: TokenRepository
    

    init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    func callAsFunction(key: String, value: String) -> Bool {
        return tokenRepository.saveToken(key: key, value: value)
    }
}
