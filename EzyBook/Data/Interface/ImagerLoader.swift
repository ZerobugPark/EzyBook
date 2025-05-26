//
//  ImagerLoader.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import Foundation

protocol ImagerLoader {
    func loadImage(from path: String) async throws ->  Data?
}
