//
//  AdvertisementTagView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI

struct AdvertisementTagView: View {
    
    
    var body: some View {
        Label {
            Text("광고")
                .appFont(PretendardFontStyle.body3, textColor: .grayScale0)
        } icon: {
            Image(.iconInfo)
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.grayScale0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial.opacity(0.5))
        .clipShape(Capsule())
        
    }
}

#Preview {
    AdvertisementTagView()
}
