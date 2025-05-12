//
//  APIError.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

enum RequestType {
    case auth
    case user
}


enum APIError: Int, Error {
    case requiredFieldMissing = 400 // 필수값이 없을 때
    case invalidRefreshToken = 401 // 인증할 수 없는 리프레시 토큰 // 계정 확인
    case emailUnavailable = 409 // 사용 불가능한 이메일 또는 이미 가입된 유저
    case expiredRefreshToken = 418 // 토큰 만료
    case unknown
    
    init(statusCode: Int) {
         self = APIError(rawValue: statusCode) ?? .unknown
     }
    
    var defaultMessage: String {
        switch self {
        case .requiredFieldMissing:
            return "필수값을 채워주세요."
        case .invalidRefreshToken:
            return "토큰 또는 계정을 확인해주세요."
        case .emailUnavailable:
            return "이미 가입된 유저거나, 사용 불가능한 이메일입니다."
        case .expiredRefreshToken:
            return "토큰이 만료되었습니다."
        case .unknown:
            return "관리자 요청: 알 수 없는 오류"
        }
    }
}

extension APIError {
    func message(for context: RequestType) -> String {
        switch (self, context) {
        case (.invalidRefreshToken, .auth):
            return "인증할 수 없는 리프레시 토큰입니다."
        case (.invalidRefreshToken, .user):
            return "계정을 확인해주세요."
        default:
            return self.defaultMessage
        }
    }
}
