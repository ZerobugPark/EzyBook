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
        .commonAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowingError },
                set: { isPresented in
                    if !isPresented {
                        dismiss()
                    }
                }
            ),
            title: viewModel.output.presentedError?.message.title,
            message: viewModel.output.presentedError?.message.msg
        )
        .onAppear {
            viewModel.action(.onAppearRequested(path: path))
        }
    }
}


