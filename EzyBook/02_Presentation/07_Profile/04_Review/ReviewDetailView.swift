//
//  ReviewDetailView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/28/25.
//

import SwiftUI

struct ReviewDetailView: View {
    
    @StateObject var viewModel: ReviewDetailViewModel
    @ObservedObject var coordinator: ProfileCoordinator
    
    @EnvironmentObject var appState: AppState
    
    @State private var selectedReview: UserReviewDetailList?
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.output.groupedReviewList) { group in
                        ReviewListGroupeView(group: group) { review in
                            selectedReview = review
                        }
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
        /// 추후 리뷰 수정 추가
//        .fullScreenCover(item: $selectedReview) { review in
//
//        }
              
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .loadingOverlayModify(viewModel.output.isLoading)
        
    }
}

private extension ReviewDetailView {
    
    // MARK: 나중에 주문 내역이랑 합치는 것도 고려 대상
     
    struct ReviewListGroupeView: View {
        
        let group: GroupedReview
        let onSelectedReView: (UserReviewDetailList) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.date)
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)
                    .padding([.top, .leading], 4)
                
                ForEach(group.reviews, id: \.reviewID) { review in
                    ReviewDetailListCardView(data: review) {
                        onSelectedReView(review)
                    }
                }
            }
        }
        
    }
    
    
    // MARK: - Card Component
    struct ReviewDetailListCardView: View {
        let data: UserReviewDetailList
        let onSelect: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                ReviewListMainContentView(data: data)
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
                    
                    
                    if !data.reviewImageURLs.isEmpty {
                        RemoteImageView(path: data.reviewImageURLs[0])
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
              
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
