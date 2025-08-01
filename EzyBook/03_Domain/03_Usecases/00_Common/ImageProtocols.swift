//
//  ImageProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/31/25.
//

import SwiftUI

protocol LoadImageOriginalUseCase {
    func execute(path: String) async throws -> UIImage
}

protocol ThumbnailImageUseCase {
    func execute(path: String, scale: CGFloat) async throws -> UIImage
}
