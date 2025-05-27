//
//  TokenInterceptor.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation
import Alamofire


/// 추상화가 필요없을 거 같은데,
/// Swift6 Sendable 문제로 인해서 구조체로 변경
/// 인터셉터는 단순 재시도만 하기 때문에, 외부에서 참조할만한게 없기 때문에, 구조체로 변경
struct TokenInterceptor: RequestInterceptor {
    
    private let tokenService: TokenRefreshable
    
    init(tokenService: TokenRefreshable) {
        self.tokenService = tokenService
    }
    
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void
    ) {
        var request = urlRequest
        if request.value(forHTTPHeaderField: "No-Auth") != "true" {
            /// 토큰 추가
            /// 헤더 설정, HTTPHeaders가 아닌 forHTTPHeaderField로 설정해도 Alamofire 내부적으로 forHTTPHeaderField 사용해서 보내기 때문에 상관 없음 )
            if let token = tokenService.accessToken {
                request.setValue(token, forHTTPHeaderField: "Authorization")
            }
        } else {
            /// 헤더 제거 (선택사항)
            request.setValue(nil, forHTTPHeaderField: "No-Auth")
        }
        completion(.success(request))
    }
    
    @preconcurrency
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping @Sendable (RetryResult) -> Void
    ) {
        
        print("here")
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        
        if response.statusCode == 419 {
            Task {
                do {
                    try await tokenService.refreshToken()
                    completion(.retry)
                } catch {
                    completion(.doNotRetryWithError(error))
                }
            }
            
        } else {
            /// 해당 상태코드가 아니면  더 이상 retry하지 않겠다 라고 else 추가해줘야함...
            completion(.doNotRetryWithError(error))
        }
        
    }
    
}
