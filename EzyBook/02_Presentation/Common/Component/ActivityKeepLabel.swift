//
//  ActivityKeepLabel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI

struct ActivityKeepLabel: View {
    
    let keepCount: Int
    
    init(keepCount: Int) {
        self.keepCount = keepCount
    }
    
    var body: some View {
        
        HStack(spacing: 4) { // ← 간격 줄이기
            Image(.iconLikeFill)
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.rosyPunch)

            Text("\(keepCount)개")
                .appFont(PaperlogyFontStyle.caption)
        }
        .padding(.vertical, 2) 


    }
}

#Preview {
    ActivityKeepLabel(keepCount: 155)
}
