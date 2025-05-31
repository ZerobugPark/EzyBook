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
        let router = UserPostRequest.emailValidation(body: body)
        
        _ = try await networkService.fetchData(dto: EmailValidationResponseDTO.self, router)
        
    }
    
    func signUp(_ router: UserPostRequest) async throws {
        _ = try await networkService.fetchData(dto: JoinResponseDTO.self, router)
    }
    
}

// MARK:  Login
extension DefaultAuthRepository {
    
    func requestEmailLogin(_ router: UserPostRequest) async throws -> LoginEntity {
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        print(data)
        return data.toEntity()
    }
    
    /// 카카오 로그인
    func requestKakaoLogin(_ token: String) async throws -> LoginEntity {
        
        let requestDto = KakaoLoginRequestDTO(oauthToken: token, deviceToken: nil)
        let router = UserPostRequest.kakaoLogin(body: requestDto)
        
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    func requestAppleLogin(_ token: String, _ name: String?) async throws -> LoginEntity {
        let requestDto = AppleLoginRequestDTO(idToken: token, deviceToken: nil, nick: name)
        let router = UserPostRequest.appleLogin(body: requestDto)
        
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        
        return data.toEntity()
    }
}
