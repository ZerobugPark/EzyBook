//
//  LoadingOverlayView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import SwiftUI

struct LoadingOverlayView: View {
    
    let isLoading: Bool
    
    var body: some View {
        if isLoading {
            Color.white.opacity(0.3)
                .ignoresSafeArea(edges: .all)
                .overlay(
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .grayScale100))
                )
                .transition(.opacity)
                .animation(.easeInOut, value: isLoading)
        }
    }
}

#Preview {
    
}
