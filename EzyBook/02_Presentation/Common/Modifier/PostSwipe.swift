//
//  PostSwipe.swift
//  EzyBook
//
//  Created by youngkyun park on 8/10/25.
//


import SwiftUI

// MARK: - ViewModifier
private struct PostSwipeModifier<Actions: View>: ViewModifier {
    let enabled: Bool
    let allowsFullSwipe: Bool
    @ViewBuilder let actions: () -> Actions

    @ViewBuilder
    func body(content: Content) -> some View {
        if enabled {
            content
                .swipeActions(edge: .leading, allowsFullSwipe: allowsFullSwipe) {
                    actions()
                }
        } else {
            content
        }
    }
}

// MARK: - View Extension (사용자 API)
extension View {
    /// 조건부로 trailing swipe actions를 적용하는 모디파이어
    /// - Parameters:
    ///   - enabled: true일 때만 swipe 적용
    ///   - allowsFullSwipe: 풀 스와이프 자동 실행 여부 (기본 false 권장)
    ///   - actions: 스와이프 액션 버튼들
    func postSwipe<Actions: View>(enabled: Bool, allowsFullSwipe: Bool = false, @ViewBuilder actions: @escaping () -> Actions) -> some View {
        modifier(PostSwipeModifier(enabled: enabled, allowsFullSwipe: allowsFullSwipe, actions: actions))
    }
}
