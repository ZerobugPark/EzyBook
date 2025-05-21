//
//  DefaultsSocialLoginService.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation
import AuthenticationServices
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser



final class DefaultsSocialLoginService: SocialLoginService {
    
    /// UserApi.shared.loginWithKakaoTalk(completion:)
    /// UserApi.shared.loginWithKakaoAccount(completion:)
    /// withCheckedThrowingContinuation -> completionHandler를 async, await처럼 쓰게 도와줌
    @MainActor
    func loginWithKakao() async throws -> String {
        return try await withCheckedThrowingContinuation { [weak self]  continuation in
            
            guard let self = self else { return }
            
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                    if let _ = error {
                        continuation.resume(throwing: APIError(type: .kakao, message: "카카오 로그인 오류"))
                    } else if let token = oauthToken?.accessToken {
                        continuation.resume(returning: token)
                        self?.fetchUserInfo()
                    } else {
                        continuation.resume(throwing: APIError(type: .kakao, message: "토근 오류"))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                    if let _ = error {
                        continuation.resume(throwing: APIError(type: .kakao, message: "카카오 로그인 오류"))
                    } else if let token = oauthToken?.accessToken {
                        continuation.resume(returning: token)
                        self?.fetchUserInfo()
                    } else {
                        continuation.resume(throwing: APIError(type: .kakao, message: "토근 오류"))
                    }
                }
            }
        }
    }
    
    
    
    // 나중에 사용할지 안할지 고민
    private func fetchUserInfo() {
        //        UserApi.shared.me { user, error in
        //            if let error = error {
        //                print("사용자 정보 가져오기 실패: \(error)")
        //            } else {
        //                if let user = user {
        //                    print("✅ 사용자 정보 가져오기 성공")
        //                    //self.userInfo = user // 사용자 정보를 상태에 저장
        //
        //                    // 유저 ID
        //                    print("ID: \(user.id ?? 0)")
        //
        //                    // 닉네임
        //                    let nickname = user.kakaoAccount?.profile?.nickname ?? "없음"
        //                    print("닉네임: \(nickname)")
        //
        //                    // 이메일
        //                    let email = user.kakaoAccount?.email ?? "이메일 없음"
        //                    print("이메일: \(email)")
        //
        //                    // 프로필 이미지
        //                    let profileImage = user.kakaoAccount?.profile?.profileImageUrl?.absoluteString ?? "없음"
        //                    print("프로필 이미지: \(profileImage)")
        //                }
        //            }
        //        }
    }
    
    
    
}

// MARK: Apple Login
extension DefaultsSocialLoginService {
    
    func loginWithApple(_ result: Result<ASAuthorization, any Error>) async throws -> (token: String, name: String?) {
        switch result {
        case .success(let authResults):
            switch authResults.credential{
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                // 계정 정보 가져오기
//                let UserIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let name =  (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
//                let email = appleIDCredential.email
//                let IdentityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
//                let AuthorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)
                
                let identityToken = appleIDCredential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
                guard let token = identityToken else {
                    throw APIError(type: .apple, message: "Invalid identity token")
                }
                return (token, name)
            default:
                // "Unsupported credential type: iCloud 키체인 자동 로그인"
                throw APIError(type: .apple, message: "키체인 자동 로그인은 불러올 수 없습니다.")
            }
        case .failure(let error):
            throw APIError(type: .apple, message: error.localizedDescription)
        }
    }
    
    
}
