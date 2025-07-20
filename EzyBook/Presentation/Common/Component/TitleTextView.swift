//
//  TitleTextView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/12/25.
//

import SwiftUI

struct TitleTextView: View {
    
    let title: String
    
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
    }
}

