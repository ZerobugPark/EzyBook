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
    private let videoLoaderDelegate: VideoLoaderDelegate
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()

    
    init(videoLoader: VideoLoaderDelegate) {
        self.videoLoaderDelegate = videoLoader
        transform()
    }
    
    
}

// MARK: Input/Output
extension VideoPlayerViewModel {
    
    struct Input { }
    
    struct Output {
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var player: AVPlayer?
    }
    
    func transform() { }
    

    private func preparePlayer(with path: String) {
        let player = createPlayer(with: path)
        observePlayerStatus(player)
        output.player = player
    }
    
    // Player 생성 및 delegate 연결
    private func createPlayer(with path: String) -> AVPlayer {
        let fakeURL = URL(string: "customscheme://\(path)")!
        videoLoaderDelegate.path = path
        
        let asset = AVURLAsset(url: fakeURL)
        asset.resourceLoader.setDelegate(videoLoaderDelegate, queue: .main)
        
        let item = AVPlayerItem(asset: asset)
        return AVPlayer(playerItem: item)
    }

    
    private func observePlayerStatus(_ player: AVPlayer) {
        guard let item = player.currentItem else { return }
        
        item.publisher(for: \.status)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    player.play()
                case .failed:
                    self?.output.presentedMessage = DisplayMessage.error(code: -1, msg: "비디오 로딩 오류")
                default: break
                }
            }
            .store(in: &cancellables)
    }
    
    
}

// MARK: Action
extension VideoPlayerViewModel {
    
    enum Action {
        case onAppearRequested(path: String)
    }
    
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested(let path):
            preparePlayer(with: path)
                  
        }
    }
    
    
}


// MARK: Alert 처리
extension VideoPlayerViewModel: AnyObjectWithCommonUI {
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    var isSuccessMessage: Bool { output.presentedMessage?.isSuccess ?? false }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
    
}

