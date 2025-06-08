//
//  BackButtonView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/3/25.
//

import SwiftUI

struct BackButtonView: View {
    
    var action: () -> Void = { }

    
    var body: some View {
        Button(action: action) {
            Image(.iconChevron)
                .renderingMode(.template)
                .foregroundStyle(.blackSeafoam)
        }
    }
}

#Preview {
    BackButtonView()
}



