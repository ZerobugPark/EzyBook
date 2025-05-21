//
//  EntityConvertible.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

/// Data → Domain 방향의 흐름을 위해 존재하는 "브리지 역할"
/// DTO는 Data 계층의 산물이기 때문에, 그 내부에서 .toEntity() 같은 변환을 제공
/// E: Entity의 약어
protocol EntityConvertible {
    associatedtype E
    func toEntity() -> E
}
