//
//  BannerView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import SwiftUI

struct BannerView: View {
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: BannerViewModel
    
    var onBannerTap: ((BannerEntity) -> Void)? = nil
    
    @State private var currentIndex = 0
    
    @State private var autoScrollTask: Task<Void, Never>? = nil
    
    var body: some View {
        TabView(selection: $currentIndex) {
            
            ForEach(Array(viewModel.output.bannerList.enumerated()), id: \.offset) { index, data in
                
                RemoteImageView(path: data.imageURL)
                    .scaledToFit()
                    .clipped()
                    .contentShape(Rectangle())
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            stopAutoScroll()
                            onBannerTap?(data)
                        }
                    )
                    .tag(index)
                
            }
            
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // ... 인디케이터 자동 생성
        .frame(height: 130)
        .onDisappear {
            stopAutoScroll()
        }
        .onChange(of: viewModel.output.bannerList.count) { newCount in
            ///  이미지 로딩 완료 후 자동 스크롤 시작
            stopAutoScroll()
            if newCount > 1 {
                if currentIndex >= newCount { // ✅ 기존 인덱스가 새 count보다 크면 마지막 인덱스로 이동
                    currentIndex = max(0, newCount - 1)
                }
                startAutoScroll()
            }
        }
        .onChange(of: currentIndex) { _ in
            ///  유저 스와이프 시 타이머 재시작
            restartAutoScroll(after: 1.5)
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
    }
    
    private func startAutoScroll() {
        stopAutoScroll()
        
        let imageCount = viewModel.output.bannerList.count
        guard imageCount > 1 else { return }
        
        autoScrollTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    withAnimation {
                        currentIndex = (currentIndex + 1) % imageCount
                    }
                }
            }
        }
    }
     
    
    
    private func stopAutoScroll() {
        autoScrollTask?.cancel()
        autoScrollTask = nil
    }
    
    @MainActor
    private func restartAutoScroll(after delay: Double = 0) {
        stopAutoScroll()
        guard viewModel.output.bannerList.count > 1 else { return }

        autoScrollTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            startAutoScroll()
        }
    }
    
    
}

