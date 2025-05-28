//
//  ActivityPointMoneyLabel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI

struct ActivityPointMoneyLabel: View {
    
    let pointReward: Int
    
    init(pointReward: Int) {
        self.pointReward = pointReward
    }
    
    var body: some View {
        
        HStack(spacing: 4) {
            Image(.iconPoint)
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.blackSeafoam)
            
            Text("\(pointReward)P")
                .appFont(PretendardFontStyle.body3)
        }
        .padding(.vertical, 2)
        
        
    }
}

#Preview {
    ActivityPointMoneyLabel(pointReward: 100)
}
