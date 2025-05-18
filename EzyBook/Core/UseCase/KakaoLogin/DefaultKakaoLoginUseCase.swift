//
//  DefaultKakaoLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

final class DefaultKakaoLoginUseCase: KakaoLoginUseCase {
    private let kakoLoginRepository: EzyBookKakaoLoginRepository
    
    init(kakoLoginRepository: EzyBookKakaoLoginRepository) {
        self.kakoLoginRepository = kakoLoginRepository
    }
    
    func callAsFunction()  {
        kakoLoginRepository.loginWithKakao()
        
    }
    
}
