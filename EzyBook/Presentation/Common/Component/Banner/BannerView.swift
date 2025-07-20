//
//  BannerView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import SwiftUI

struct BannerView: View {
    
    @ObservedObject var viewModel: BannerViewModel
    
    @State private var currentIndex = 0
    @State private var timer: Timer? = nil
    @Environment(\.displayScale) var scale
    
    
    var body: some View {
        TabView(selection: $currentIndex) {

            ForEach(Array(viewModel.output.bannerList.enumerated()), id: \.offset) { index, data in
                Image(uiImage: data.bannerImage ?? UIImage(systemName: "star.fill")!)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .tag(index) // ✅ 필수
            }
            
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // ... 인디케이터 자동 생성
        .frame(height: 130)
        .onAppear {
            viewModel.action(.updateScale(scale: scale))
            viewModel.action(.onAppearRequested)
        }
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
            stopAutoScroll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if viewModel.output.bannerList.count > 1 {
                    startAutoScroll()
                }
            }
        }
    }
    
    private func startAutoScroll() {
        stopAutoScroll()
        
        let imageCount = viewModel.output.bannerList.count
        guard imageCount > 1 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % imageCount
            }
        }
    }
    
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    
}

