//
//  EntityConvertible.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

protocol EntityConvertible {
    associatedtype E: StructEntity
    func toEntity() -> E
}
