//
//  ImagerLoader.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import SwiftUI

protocol ImageLoder {
    func fetchImageData(from url: String, etag: String?) async throws -> ImageResponse
}
