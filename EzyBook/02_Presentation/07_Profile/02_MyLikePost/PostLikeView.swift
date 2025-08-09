//
//  PostLikeView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/10/25.
//

import SwiftUI

struct PostLikeView: View {
    
    @StateObject var viewModel: PostLikeViewModel
    @ObservedObject var coordinator: ProfileCoordinator
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        ZStack {
            
            List {
                ForEach(Array(viewModel.output.likeList.enumerated()), id: \.element.id) { index, post in
                    
                    PostLikeCardView(data: post)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                viewModel.action(.removePost(postID: post.postID))
                            } label: {
                                Label("좋아요 취소", systemImage: "heart.slash")
                            }
                            .tint(.red)
                        }
                        .onAppear {
                            let triggerIndex = max(0, viewModel.output.likeList.count - 3)
                            guard index == triggerIndex else { return }
                            viewModel.action(.paginationLikeList)
                        }
                }
            }
            .listStyle(.plain)
            .disabled(viewModel.output.isLoading)
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("액티비티")
                    .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
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


extension PostLikeView {
    // MARK: - Card Component
    struct PostLikeCardView: View {
        let data: PostSummaryEntity
        
        var body: some View {
            VStack(spacing: 0) {
                LikeListMainContentView(data: data)
            }
            .background(.grayScale0)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
    }
    
    // MARK: - Main Content
    struct LikeListMainContentView: View {
        let data: PostSummaryEntity
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.title)
                            .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
                            .multilineTextAlignment(.leading)
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("작성자: \(data.creator.nick)")
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
                            
                            Text("국가: \(data.country) 카테고리: \(data.category)")
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                            
                            Text("content")
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
                            
                            Text(data.content)
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                                .lineLimit(2)
                            
                        }

                    }
                    
                    Spacer()
                    
                    if !data.files.isEmpty {
                        RemoteImageView(path: data.files[0] )
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                }
                .padding(16)
                .background(.grayScale0)
                .cornerRadius(12)
                .contentShape(Rectangle())
            }
        }
        
    }
}
