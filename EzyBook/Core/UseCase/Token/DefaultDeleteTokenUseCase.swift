//
//  DefaultDeleteTokenUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

final class DefaultDeleteTokenUseCase: DeleteTokenUseCase {
    private let tokenRepository: KeychainTokenRepository
    

    init(tokenRepository: KeychainTokenRepository) {
        self.tokenRepository = tokenRepository
    }

    func callAsFunction(key: String) -> Bool {
        return tokenRepository.deleteToken(key: key)
    }
}
