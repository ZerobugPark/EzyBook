//
//  SaveTokenUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

protocol SaveTokenUseCase {
    func callAsFunction(key: String, value: String) -> Bool
}
