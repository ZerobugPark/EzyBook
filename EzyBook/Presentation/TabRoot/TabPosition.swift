//
//  TabPosition.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import SwiftUI

/// Custom View Extension
/// Witch will Return View Position
///
struct PositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value  = nextValue()
    }
}

extension View {
    @ViewBuilder
    func viewPosition(completionHandler: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let rect = $0.frame(in: .global)
                    
                    Color.clear
                        .preference(key: PositionKey.self, value: rect)
                        .onPreferenceChange(PositionKey.self, perform: completionHandler)
                }
            }
    }
}
