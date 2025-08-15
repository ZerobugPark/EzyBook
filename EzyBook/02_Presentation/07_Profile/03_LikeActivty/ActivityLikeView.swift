//
//  ActivityLikeView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/10/25.
//

import SwiftUI

struct ActivityLikeView: View {
    
    @EnvironmentObject var appState: AppState
    private let coordinator: ProfileCoordinator
    @StateObject var viewModel: ActiviyLikeViewModel
    
    init(coordinator: ProfileCoordinator, viewModel: ActiviyLikeViewModel) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    var body: some View {
        
        ZStack {
            
            List {
                ForEach(Array(viewModel.output.likeList.enumerated()), id: \.element.activityID) { index, activity in
                    
                    ActivityLikeCardView(data: activity)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                viewModel.action(.removeActivity(activityID: activity.activityID))
                            } label: {
                                Label("좋아요 취소", systemImage: "heart.slash")
                            }
                            .tint(.rosyPunch)
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


private extension ActivityLikeView {
    
    // MARK: - Card Component
    struct ActivityLikeCardView: View {
        let data: ActivitySummaryEntity
        
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
        let data: ActivitySummaryEntity
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.title)
                            .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
                            .multilineTextAlignment(.leading)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("국가: \(data.country) 카테고리: \(data.category)")
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                            
                            Text("결제 금액: \(data.price.final)원")
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
                        }
                    }
                    
                    Spacer()
                    
                    RemoteImageView(path: data.thumbnails[0])
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

