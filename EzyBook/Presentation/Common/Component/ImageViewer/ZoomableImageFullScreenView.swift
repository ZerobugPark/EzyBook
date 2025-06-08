//
//  ZoomableImageFullScreenView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import SwiftUI

struct ZoomableImageFullScreenView: View {
    let path: String
    @Environment(\.dismiss) var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("hello")
            Image(.flagArgentina)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = max(1.0, value)
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { value in
                            lastOffset = offset
                        }
                )
                .onTapGesture {
                    dismiss()
                }
        }
    }
}
