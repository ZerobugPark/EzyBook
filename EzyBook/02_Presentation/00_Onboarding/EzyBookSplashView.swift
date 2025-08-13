//
//  EzyBookSplashView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/13/25.
//

import SwiftUI

struct EzyBookSplashView: View {
    var body: some View {
        Text("당신을 위한 액티비티 예약\n EzyBook")
            .appFont(PaperlogyFontStyle.title)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
               
    }
}

#Preview {
    EzyBookSplashView()
}
