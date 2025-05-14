//
//  EntityConvertible.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

protocol EntityConvertible {
    associatedtype T
    func toEntity() -> T
}
