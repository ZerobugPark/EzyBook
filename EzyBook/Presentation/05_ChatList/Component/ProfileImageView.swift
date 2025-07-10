//
//  ProfileImageView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import SwiftUI

struct ProfileImageView: View {
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.blue.opacity(0.2))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.blue)
            )
    }
}

