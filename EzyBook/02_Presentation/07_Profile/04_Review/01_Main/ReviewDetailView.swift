//
//  ReviewDetailView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/28/25.
//

import SwiftUI

struct ReviewDetailView: View {
    
    @EnvironmentObject var appState: AppState
    
    private let coordinator: ProfileCoordinator
    @StateObject var viewModel: ReviewDetailViewModel

    private let onFinished: (UserReviewDetailList?) -> (Void)
    
    init(coordinator: ProfileCoordinator, viewModel: ReviewDetailViewModel, onFinished: @escaping (UserReviewDetailList?) -> Void) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinished = onFinished
    }
    
    
    @State private var selectedReview: UserReviewDetailList?
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.output.groupedReviewList) { group in
                        ReviewListGroupeView(group: group, actions: ReviewAction(
                            onEdit: { data in
                                selectedReview = data
                            },
                            onDelete: { data in
                                viewModel.action(.deleteReview(data: data))
                            })
                        )
                        
                    }
                    
                }
                .padding(.horizontal, 20)
                
            }
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
                Text("리뷰 내역")
                    .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
            }
        }
        
        .fullScreenCover(item: $selectedReview) { review in
            coordinator.makeModifyReviewView(review) { result in
                onFinished(result)
            }
        }
        
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .loadingOverlayModify(viewModel.output.isLoading)
        .onDisappear {
            NotificationCenter.default.post(name: .updatedProfileSupply, object: nil)
        }
        
    }
}

private extension ReviewDetailView {
    
    struct ReviewAction {
        
        let onEdit: (UserReviewDetailList) -> Void
        let onDelete: (UserReviewDetailList) -> Void
    }
    
    struct ReviewListGroupeView: View {
        
        let group: GroupedReview
        let actions: ReviewAction
        
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.date)
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)
                    .padding([.top, .leading], 4)
                
                ForEach(group.reviews, id: \.reviewID) { review in
                    ReviewDetailListCardView(data: review, actions: actions)
                }
            }
        }
        
    }
    
    
    // MARK: - Card Component
    struct ReviewDetailListCardView: View {
        let data: UserReviewDetailList
        let actions: ReviewAction
        
        var body: some View {
            VStack(spacing: 0) {
                ReviewListMainContentView(data: data, actions: actions)
                ReViewListRatingView(data: data)
            }
            .background(.grayScale0)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Main Content
    struct ReviewListMainContentView: View {
        let data: UserReviewDetailList
        let actions: ReviewAction
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.title)
                            .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
                            .multilineTextAlignment(.leading)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("투어 일자: \(data.reservationItemName)")
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                            
                            Text("후기")
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
                            Text(data.content)
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                            
                            
                        }
                    }
                    
                    Spacer()
                    
                    
                    ActionButtonView {
                        actions.onEdit(data)
                    } onDelete: {
                        actions.onDelete(data)
                    }
                    .padding(.top, 5)
                    
                    
                }
            }
            .padding(16)
            .background(.grayScale0)
            .cornerRadius(12)
        }
    }
    
    
    // MARK: - Rating View
    struct ReViewListRatingView: View {
        let data: UserReviewDetailList
        
        var body: some View {
            HStack(alignment: .center, spacing: 6) {
                Spacer()
                Image(.iconStarFill)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.rosyPunch)
                
                Text("\(data.rating)")
                    .appFont(PretendardFontStyle.body2, textColor: .grayScale100)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
    }
    
    
}

struct ActionButtonView: View {
    
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        
        
        Button(action: {
            print("tapped")
            isPresented = true
        }) {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .foregroundColor(.gray)
        }
        .confirmationDialog("", isPresented: $isPresented, titleVisibility: .hidden) {
            Button("수정하기", action: onEdit)
            Button("삭제하기", role: .destructive, action: onDelete)
            Button("닫기", role: .cancel) { }
        }
        
        
    }
}
