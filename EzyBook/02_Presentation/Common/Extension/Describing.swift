//
//  Describing.swift
//  EzyBook
//
//  Created by youngkyun park on 8/11/25.
//

import Foundation

protocol Describing: AnyObject {
    static var desc: String { get }
    var desc: String { get }
}

extension Describing {
    static var desc: String { String(describing: Self.self) }
    var desc: String { String(describing: type(of: self)) }
}
