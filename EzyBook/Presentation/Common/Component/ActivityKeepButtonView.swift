//
//  ActivityKeepButtonView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI

struct ActivityKeepButtonView: View {
    let isKeep: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(isKeep ? .iconLikeFill : .iconLikeEmpty)
                .renderingMode(.template)
                .foregroundStyle(isKeep ? .rosyPunch : .grayScale0)
        }
        .buttonStyle(.plain) // 탭 영역은 유지하되 버튼 기본 스타일 제거
    }
}
