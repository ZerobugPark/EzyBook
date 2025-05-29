//
//  ActivityOpenDisCountTagView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI

struct ActivityOpenDisCountTagView: View {

    var body: some View {
        Label {
            Text("NEW 액티비티 오픈할인")
                .appFont(
                    PaperlogyFontStyle.caption,
                    textColor: .grayScale0
                )
        } icon: {
            Image(.iconNoti)
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
    ActivityOpenDisCountTagView()
}
