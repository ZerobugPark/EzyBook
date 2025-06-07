//
//  VideoPlayerViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import SwiftUI
import AVKit
import Combine

final class VideoPlayerViewModel: ViewModelType {

    
    var input = Input()
    private let videoLoader: VideoLoaderDelegate
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()

    
    init(videoLoader: VideoLoaderDelegate) {
        self.videoLoader = videoLoader
        transform()
    }
    
    
}

// MARK: Input/Output
extension VideoPlayerViewModel {
    
    struct Input {
        
        
    }
    
    struct Output {
        
        var player: AVPlayer?
        
    }
    
    func transform() {
        
        
    }
    
    // Player 생성 및 delegate 연결
    private func preparePlayer(with path: String) {
        let fakeURL = URL(string: "customscheme://\(path)")!
        videoLoader.path = path
        
        let asset = AVURLAsset(url: fakeURL)
        asset.resourceLoader.setDelegate(videoLoader, queue: .main)
     
        
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        // ✅ 재생 준비 상태 관찰 후 play
         item.publisher(for: \.status)
             .sink { [weak self] status in
                 if status == .readyToPlay {
                     print("✅ ready to play, playing now")
                     player.play()
                 } else if status == .failed {
                     print("❌ playerItem failed:", item.error ?? "Unknown error")
                 }
             }
             .store(in: &cancellables)
        
        output.player = player
    }
}

// MARK: Action
extension VideoPlayerViewModel {
    
    enum Action {
        case onAppearRequested(path: String)
      
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested(let path):
            preparePlayer(with: path)
                  
        }
    }
    
    
}

