//
//  VideoPlayerView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let path: String
    @StateObject var viewModel: VideoPlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if let player = viewModel.output.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView("로딩 중...")
            }
            
            Button(action: {
                dismiss() // 전체화면 닫기
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .padding()
                    .foregroundColor(.white)
                    .shadow(radius: 10)
            }
        }
        .onAppear {
            viewModel.action(.onAppearRequested(path: path))
        }
    }
}


