//
//  APIError.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

enum APIError: Error {
    // 서버 에러 (HTTP 상태 코드 기반)
    case serverError(code: Int, message: String?)
    
    // 로컬 에러 (클라이언트 측)
    case localError(type: LocalErrorType, message: String?)
    
    // 원시 데이터가 있는 에러 (파싱이 필요한 경우)
    case dataError(code: Int, data: Data?)
    
    case socialLoginError(message: String)
    
    case unknown
    
    // 소셜 로그인 타입
    enum SocialLoginType: String {
        case kakao
        case apple
    }
    // 로컬 에러 타입
    enum LocalErrorType: Int {
        case missingEndpoint
        case missingRequestBody
        case decodingError
        case tokenNotFound
        case seifIsNil
        case invalidMediaType
        case thumbnailFailed
        // 기타 로컬 에러 타입
    }
    
    // HTTP 상태 코드에서 생성
    init(statusCode: Int, data: Data? = nil) {
        // data가 있으면 dataError로 처리
        if let data = data {
            self = .dataError(code: statusCode, data: data)
            return
        }
        
        switch statusCode {
        case 400:
            self = .serverError(code: statusCode, message: "필수값을 채워주세요.")
        case 401:
            self = .serverError(code: statusCode, message: "토큰 또는 계정을 확인해주세요.")
        case 409:
            self = .serverError(code: statusCode, message: "이미 가입된 유저거나, 사용 불가능한 이메일입니다.")
        case 418:
            self = .serverError(code: statusCode, message: "토큰이 만료되었습니다.")
        default:
            self = .serverError(code: statusCode, message: "알 수 없는 오류가 발생했습니다.")
        }
    }
    
    // 로컬 에러 타입에서 생성
    init(localErrorType: LocalErrorType) {
        switch localErrorType {
        case .missingEndpoint:
            self = .localError(type: localErrorType, message: "endPoint를 확인해주세요.")
        case .missingRequestBody:
            self = .localError(type: localErrorType, message: "요청 바디가 유효하지 않습니다.")
        case .decodingError:
            self = .localError(type: localErrorType, message: "디코딩 타입을 확인해주세요.")
        case .tokenNotFound:
            self = .localError(type: localErrorType, message: "토큰을 불러올 수 없습니다")
        case .seifIsNil:
            self = .localError(type: localErrorType, message: "self가 없습니다.")
        case .invalidMediaType:
            self = .localError(type: localErrorType, message: "지원하지 않는 미디어 타입")
        case .thumbnailFailed:
            self = .localError(type: localErrorType, message: "썸네일 생성 실패")
        }
    }
    
    // SocialLogin Error 타입 생성
    init(type: SocialLoginType, message: String? = nil) {
        switch type {
        case .kakao:
            self = .socialLoginError(message: message ?? "카카오 로그인 오류")
        case .apple:
            self = .socialLoginError(message: message ?? "애플 로그인 오류")
        }
    }
    
    // 에러 코드
    var code: Int {
        switch self {
        case .serverError(let code, _):
            return code
        case .localError(let type, _):
            return type.rawValue
        case .dataError(let code, _):
            return code
        case .socialLoginError(_), .unknown:
            return -1
        }
    }
    
    // 사용자에게 보여줄 메시지
    var userMessage: String {
        switch self {
        case .serverError(_, let message):
            return message ?? "서버 오류가 발생했습니다."
        case .localError(_, let message):
            return message ?? "앱 오류가 발생했습니다."
        case .dataError(_, let data):
            if let data = data {
                let decoder = ResponseDecoder()
                let errorResponse = decoder.decode(data: data, type: ErrorMessageDTO.self)
                switch errorResponse {
                case .success(let success):
                    return success.message
                case .failure(let error):
                    return error.userMessage
                }
            }
            return "오류가 발생했습니다."
        case .socialLoginError(let message):
            return message
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
    
}
