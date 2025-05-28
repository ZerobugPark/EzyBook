//
//  EventTag.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI

enum Tag {
    case hot
    case new
}

struct EventTag: View {
    
    private let tag: Tag
    
    init(tag: Tag) {
        self.tag = tag
    }
    
    var body: some View {
        Label {
            Text(tag == .hot ? "HOT" : "NEW")
                .appFont(
                    PretendardFontStyle.body3,
                    textColor: tag == .hot ? .red : .deepSeafoam
                )
        } icon: {
            Image(tag == .hot ? .iconHot : .iconNew)
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(tag == .hot ? .red : .deepSeafoam)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.grayScale15, lineWidth: 0.3)
                .shadow(radius: 0.1)
        )
        
    }
}

#Preview {
    EventTag(tag: .hot)
}
