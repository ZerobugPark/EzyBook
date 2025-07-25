//
//  LoginBundle.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation


struct SocialLoginUseCases {

    let appleLogin: AppleLoginUseCase
    let kakaoLogin: KakaoLoginUseCase
    
}

struct CreateAccountUseCases {
    let signUp: SignUpUseCase
    let verifyEmail: VerifyEmailUseCase
}


