//
//  UserEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation



struct ProfileCheckEntity {
    let userID: String
    let email: String
    let nick: String
    let profileImage: String?
    let phoneNum: String
    let introduction: String
    
    var profileImageData: Data? {
        //Todo
        // Image로 변환하는 작업 필요
        return nil
    }
    
}

struct EmailValidationEntity {
    let message: String
}


/// 회원가입
struct JoinEntity {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
    
}

/// 로그인 (이메일, 카카오, 애플 공통)
struct LoginEntity {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
    
}
