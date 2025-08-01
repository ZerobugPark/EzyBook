//
//  VideoPlayerView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: VideoPlayerViewModel
    
    let path: String
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let player = viewModel.output.player {
                /// resourceLoader 실행
                /// 즉 로딩을 시작해라
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView("로딩 중...")
            }
            
            Button(action: {
                dismiss() // 전체화면 닫기
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .padding(12) // 터치 영역 확보
                    .foregroundColor(.grayScale0)
                    .contentShape(Rectangle())
            }
            .padding(.top, 60)
            .padding(.trailing, 20)
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            } else {
                dismiss()
            }
            
        }
        .onAppear {
            viewModel.action(.onAppearRequested(path: path))
        }
    }
}


