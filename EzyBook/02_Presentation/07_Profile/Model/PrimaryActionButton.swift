//
//  PrimaryActionButton.swift
//  EzyBook
//
//  Created by youngkyun park on 7/27/25.
//

import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)                
                .appFont(PaperlogyFontStyle.body, textColor: .grayScale0)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isEnabled ? Color.blackSeafoam : Color.grayScale60)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
    }
}
