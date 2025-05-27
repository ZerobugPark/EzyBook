//
//  ImagerLoader.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import SwiftUI

protocol ImagerLoader {
    func loadImage(from path: String, scale: CGFloat) async throws ->  UIImage
}
