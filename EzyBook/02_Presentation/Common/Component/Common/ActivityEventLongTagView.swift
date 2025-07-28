//
//  ActivityOpenDisCountTagView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI

struct ActivityEventLongTagView: View {
    
    var tag: Tag
    
    
    var body: some View {
        Label {
            Text(tag == .new ? "NEW 액티비티 오픈할인" : "Hot 이벤트")
                .appFont(
                    PaperlogyFontStyle.caption,
                    textColor: .grayScale0
                )
        } icon: {
            Image(tag == .new ? .iconNoti : .iconHot)
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.grayScale0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.grayScale15, lineWidth: 0.3)
                .shadow(radius: 0.1)
        )
        
    }
}

#Preview {
    ActivityEventLongTagView(tag: .hot)
}
