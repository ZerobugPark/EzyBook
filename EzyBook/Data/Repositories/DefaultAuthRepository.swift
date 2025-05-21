//
//  DefaultAuthRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

final class DefaultAuthRepository: SignUpRepository, EmailLoginRepository, KakaoLoginRepository, AppleLoginRepository {

    

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 이메일 중복확인
    func verifyEmailAvailability(_ email: String) async throws {
        let body = EmailValidationRequestDTO(email: email)
        let router = UserRequest.emailValidation(body: body)
        
        _ = try await networkService.fetchData(dto: EmailValidationResponseDTO.self, router)
        
    }
    
    func signUp(_ router: UserRequest) async throws {
        _ = try await networkService.fetchData(dto: JoinResponseDTO.self, router)
    }
    
}

// MARK:  Login
extension DefaultAuthRepository {
    
    func emailLogin(_ router: UserRequest) async throws -> LoginEntity {
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        
        return data
    }
    
    /// 카카오 로그인
    func loingWithKaKao(_ token: String) async throws -> LoginEntity {
        
        let requestDto = KakaoLoginRequestDTO(oauthToken: token, deviceToken: nil)
        let router = UserRequest.kakaoLogin(body: requestDto)
        
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        
        return data
    }
    
    func loingWithApple(_ token: String) async throws -> LoginEntity {
        let requestDto = AppleLoginRequestDTO(idToken: "", deviceToken: nil, nick: nil)
        let router = UserRequest.appleLogin(body: requestDto)
        
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        
        return data
    }
}


/// 참고용
//func emailLogin(_ router: UserRequest) async throws {
//    
//    let data = try await networkManager.fetchData(dto: LoginResponseDTO.self, router)
//    
//    _ = tokenManager.saveTokens(accessToken: data.accessToken, refreshToken: data.refreshToken)
//    
//    refreshScheduler.start { [weak self] in
//        try? await self?.refreshTokenIfNeeded()
//    }
//    
//}
