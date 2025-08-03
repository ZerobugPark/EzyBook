//
//  PostDetailView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import SwiftUI

struct PostDetailView: View {
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: PostDetailViewModel
    @ObservedObject  var coordinator: CommunityCoordinator
    
    @State private var selectedIndex = 0
    /// 화면전환 트리거
    @State private var selectedMedia: SelectedMedia?
    
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PostTopMediaSection(
                        data: viewModel.output.postDetailInfo,
                        thumbnails: viewModel.output.postDetailInfo.files,
                        selectedIndex: $selectedIndex,
                        selectedMedia: $selectedMedia
                    )
   
                    PostMainContentView(data: viewModel.output.postDetailInfo)
                }
                
              
            }
            .disabled(viewModel.output.isLoading)
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
            
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(.grayScale15)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ActivityKeepButtonView(isKeep: viewModel.output.postDetailInfo.isLike) {
                    //viewModel.action(.keepButtonTapped)
                }
            }
        }
        .fullScreenCover(item: $selectedMedia) { media in
            if media.isVideo {
                coordinator.makeVideoPlayerView(path: viewModel.output.postDetailInfo.files[media.id])
            } else {
                coordinator.makeImageViewer(path: viewModel.output.postDetailInfo.files[media.id])
            }
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .loadingOverlayModify(viewModel.output.isLoading)
        
    }
}


// MARK: 이미지 섹션
private extension PostDetailView {
    struct PostTopMediaSection: View {
        let data: PostEntity
        let thumbnails: [String]
        
        @Binding var selectedIndex: Int
        @Binding var selectedMedia: SelectedMedia?
        

        
        var body: some View {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(thumbnails.enumerated()), id: \.0) { index, path in
                        ZStack {
                            RemoteImageView(path: path)
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                            
                            if thumbnails[index].hasSuffix(".mp4") {
                                Image(.playButton)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .shadow(radius: 10)
                            }
                        }
                        .onTapGesture {
                            let isVideo = thumbnails[index].hasSuffix(".mp4")
                            selectedMedia = SelectedMedia(id: index, isVideo: isVideo)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)
                
                VStack(spacing: 8) {
                    indicatorView
                }
                .padding(.bottom, 40)
            }
            
        }
        
        private var indicatorView: some View {
            HStack(spacing: 6) {
                ForEach(0..<thumbnails.count, id: \.self) { index in
                    if index == selectedIndex {
                        Capsule()
                            .fill(.grayScale45)
                            .frame(width: 30, height: 8)
                            .transition(.scale)
                    } else {
                        Circle()
                            .fill(.grayScale60)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        }
    }
}




// MARK: 타이틀 및 후기

private extension PostDetailView {
    
    struct PostMainContentView: View {
        
        let data: PostEntity
            
            
        var body: some View {
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    ProfileImageView(path: data.creator.profileImage, size: 32)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(data.creator.nick)
                            .appFont(PretendardFontStyle.body2, textColor: .grayScale90)
                        Text(data.relativeTimeDescription)
                            .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
                        
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                
                Text(data.title)
                    .appFont(PaperlogyFontStyle.body, textColor: .grayScale90)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(data.content)
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            
                
        }
            
        
        
    }
    
    
}
