//
//  ProfileImageView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import SwiftUI

struct ProfileImageView: View {
    
    let path: String?
    
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.blue.opacity(0.2))
            .frame(width: size, height: size)
            .overlay(profileOverlayView)
    }
    
    @ViewBuilder
    private var profileOverlayView: some View {
        if let path {
            RemoteImageView(path: path)
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: size, height: size)
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: size * 0.4))
                .foregroundColor(.blue)
        }
    }
}

