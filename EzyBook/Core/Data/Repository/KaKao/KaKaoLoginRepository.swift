//
//  KaKaoLoginRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser


final class KaKaoLoginRepository: EzyBookKakaoLoginRepository {

    private let networkRepository: EzyBookNetworkRepository
    private let tokenManager: TokenManager

    init(networkRepository: EzyBookNetworkRepository, tokenManager: TokenManager) {
        self.networkRepository = networkRepository
        self.tokenManager = tokenManager
    }
    
    
    func loginWithKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    print(oauthToken)
                    // 성공 시 동작 구현
                    _ = oauthToken
                }
            }
        } else {
            // 카카오 계정 로그인 시도
            print(UserApi.isKakaoTalkLoginAvailable())
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                print("oauthToken2", oauthToken)
                print(error)
                self?.fetchUserInfo()
            }
        }
    }
    
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
