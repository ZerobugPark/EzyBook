//
//  DefaultAuthRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

struct DefaultAuthRepository: SignUpRepository, EmailLoginRepository, KakaoLoginRepository, AppleLoginRepository {


    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 이메일 중복확인
    func verifyEmailAvailability(_ email: String) async throws {
        let body = EmailValidationRequestDTO(email: email)
        let router = UserRequest.Post.emailValidation(body: body)
        
        _ = try await networkService.fetchData(dto: EmailValidationResponseDTO.self, router)
        
    }
    
    func signUp(_ email: String, _ password: String, _ nick: String, _ phoneNum: String?, _ introduction: String?, _ deviceToken: String?) async throws {
    
        let body = JoinRequestDTO(
            email: email,
            password: password,
            nick: nick,
            phoneNum: phoneNum,
            introduction: introduction,
            deviceToken: deviceToken
        )
        let router = UserRequest.Post.join(body: body)
        
        
        _ = try await networkService.fetchData(dto: JoinResponseDTO.self, router)
    }
    
    
    
    
}

// MARK:  Login
extension DefaultAuthRepository {
    
    func requestEmailLogin(_ router: UserRequest.Post) async throws -> LoginEntity {
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    /// 카카오 로그인
    func requestKakaoLogin(_ token: String) async throws -> LoginEntity {
        
        let requestDto = KakaoLoginRequestDTO(oauthToken: token, deviceToken: nil)
        let router = UserRequest.Post.kakaoLogin(body: requestDto)
        
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    func requestAppleLogin(_ token: String, _ name: String?) async throws -> LoginEntity {
        let requestDto = AppleLoginRequestDTO(idToken: token, deviceToken: nil, nick: name)
        let router = UserRequest.Post.appleLogin(body: requestDto)
        
        let data = try await networkService.fetchData(dto: LoginResponseDTO.self, router)
        
        return data.toEntity()
    }
}
