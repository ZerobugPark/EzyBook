//
//  KaKaoLoginProvider.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser


final class KaKaoLoginProvider: SocialLoginProvider {
  
    /// UserApi.shared.loginWithKakaoTalk(completion:)
    /// UserApi.shared.loginWithKakaoAccount(completion:)
    /// withCheckedThrowingContinuation -> completionHandler를 async, await처럼 쓰게 도와줌
    @MainActor
    func login() async throws -> String {
        return try await withCheckedThrowingContinuation { [weak self]  continuation in
            
            guard let self = self else { return }
            
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                    if let _ = error {
                        continuation.resume(throwing: APIError(type: .kakao, message: "카카오 로그인 오류"))
                    } else if let token = oauthToken?.accessToken {
                        continuation.resume(returning: token)
                        //self?.fetchUserInfo()
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
                        //self?.fetchUserInfo()
                    } else {
                        continuation.resume(throwing: APIError(type: .kakao, message: "토근 오류"))
                    }
                }
            }
        }
    }

    

    // 나중에 사용할지 안할지 고민
    private func fetchUserInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print("사용자 정보 가져오기 실패: \(error)")
            } else {
                if let user = user {
                    print("✅ 사용자 정보 가져오기 성공")
                    //self.userInfo = user // 사용자 정보를 상태에 저장

                    // 유저 ID
                    print("ID: \(user.id ?? 0)")

                    // 닉네임
                    let nickname = user.kakaoAccount?.profile?.nickname ?? "없음"
                    print("닉네임: \(nickname)")

                    // 이메일
                    let email = user.kakaoAccount?.email ?? "이메일 없음"
                    print("이메일: \(email)")

                    // 프로필 이미지
                    let profileImage = user.kakaoAccount?.profile?.profileImageUrl?.absoluteString ?? "없음"
                    print("프로필 이미지: \(profileImage)")
                }
            }
        }
    }
    

}

