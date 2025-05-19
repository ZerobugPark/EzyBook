//
//  DefaultLoadTokenUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

final class DefaultLoadTokenUseCase: LoadTokenUseCase {
    private let tokenRepository: EzyBookTokenRepository
    

    init(tokenRepository: EzyBookTokenRepository) {
        self.tokenRepository = tokenRepository
    }

    func callAsFunction(key: String) -> String? {
        return tokenRepository.loadToken(key: key)
    }
}


