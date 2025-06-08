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
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var player: AVPlayer?
    }
    
    func transform() { }
    
    // Player 생성 및 delegate 연결
    private func preparePlayer(with path: String) {
        
        /// AVPlayer는 일반적으로 `http://` 또는 `file://` URL을 요구하지만,
        /// 여기서는 `customscheme://`로 가짜 URL을 생성해 사용합니다.
        let fakeURL = URL(string: "customscheme://\(path)")!
        
        /// 델리게이트의 실제 패스 추가
        videoLoaderDelegate.path = path
        
        
        ///  AVURLAsset 생성 → AVPlayer가 비디오 재생에 사용할 자원
        let asset = AVURLAsset(url: fakeURL)
        
        ///  AVAssetResourceLoaderDelegate로 우리가 만든 `videoLoader`를 연결
        ///  AVPlayer는 이제 네트워크 요청 대신, delegate에게 "데이터 줘"라고 요청하게 됩니다.
        asset.resourceLoader.setDelegate(videoLoaderDelegate, queue: .main)
        

        /// AVPlayerItem은 KVO(Key-Value Observing)
        /// KVO 속성은 .publihser(for:) 제공
        ///  AVPlayerItem.status는 내부적으로 Objective-C 기반으로 선언된 @objc dynamic
        let item = AVPlayerItem(asset: asset)
        
        let player = AVPlayer(playerItem: item)
        
//        | 구독 대상                        | 왜 구독할까?                       |
//        | ---------------------------- | ----------------------------- |
//        | `AVPlayerItem.status`        | 영상 준비 여부 확인용 (`.readyToPlay`) |
//        | `AVPlayer.timeControlStatus` | 재생 상태 (재생 중/정지/버퍼링 등)         |
//        | `AVPlayerItem.error`         | 개별 영상 실패 정보 확인                |

        
         item.publisher(for: \.status)
             .sink { [weak self] status in
                 switch status {
                 case .readyToPlay:
                     /// .readyToPlay: 재생할 만큼 데이터가 있다.
                     print("✅ ready to play, playing now")
                     player.play()
                 case .failed:
                     self?.output.presentedError = DisplayError.error(code: -1, msg: "비디오 로딩 오류")
                 case .unknown:
                     /// 아직 로딩 전
                     break
                 @unknown default:
                     break
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
    
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested(let path):
            preparePlayer(with: path)
                  
        }
    }
    
    
}

