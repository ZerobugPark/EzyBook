//
//  NetworkLog.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

#if DEBUG
enum NetworkLog {
    
    private static let isPrint = true
    
    /// 네트워크 성공시 출력합니다.
    static func success<T: Decodable>(
        url: String,
        statusCode: Int,
        data: T
    ) {
        let message = """
            [✅ SUCCESS]
            - endPoint: \(url)
            - statusCode: \(statusCode)
            =====================================================
            """
        
        if isPrint {
            print(message)
            dump(data)
        }
    }
    
    /// 네트워크 로그를 출력합니다.
    static func failure<T: Decodable> (
        url: String,
        statusCode: Int,
        data: T
    ) {
        let message = """
            [❌ FAILURE]
            - endPoint: \(url)
            - statusCode: \(statusCode)
            =====================================================
            """
        
        if isPrint {
            print(message)
            //dump(data)
        }
    }
}
#endif
