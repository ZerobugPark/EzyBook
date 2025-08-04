//
//  CommonNavigationBar.swift
//  EzyBook
//
//  Created by youngkyun park on 7/27/25.
//

import SwiftUI

struct CommonNavigationBar: View {
    let title: String
    var leadingAction: (() -> Void)? = nil
    var trailingAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            // Leading (닫기/뒤로가기 버튼)
            if let leadingAction = leadingAction {
                Button(action: leadingAction) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            } else {
                Spacer().frame(width: 24) // 버튼이 없을 때 균형 유지용
            }
            
            Spacer()
            
            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            
            // Trailing (옵션 버튼)
            if let trailingAction = trailingAction {
                Button(action: trailingAction) {
                   Text("저장")
                        .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                        
                }
            } else {
                Spacer().frame(width: 24)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.white)
    }
}
