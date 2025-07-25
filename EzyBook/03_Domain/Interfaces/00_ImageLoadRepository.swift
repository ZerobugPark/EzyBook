//
//  00_ImageLoadRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import SwiftUI

protocol LoadOriginalImage {
    func loadOriginalImage(from path: String) async throws -> UIImage
}

protocol LoadThumbnailImage {
    func loadMediaPreview(from path: String, scale: CGFloat) async throws -> UIImage
}

