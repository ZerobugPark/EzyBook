//
//  ImagerLoader.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import SwiftUI

protocol ImagerLoader {
    var imageCache: ImageCache { get }
    func loadMediaPreview(from path: String, scale: CGFloat) async throws -> UIImage
    func loadOriginalImage(from path: String) async throws -> UIImage
}
