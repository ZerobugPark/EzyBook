//
//  ReviewView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import SwiftUI



struct ReviewView: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: ReviewViewModel
    @ObservedObject var coordinator: HomeCoordinator
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                if viewModel.output.reviewList.isEmpty {
                    VStack {
                        Spacer()
                        Text("아직 작성된 후기가 없습니다.")
                            .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .frame(minHeight: UIScreen.main.bounds.height * 0.6)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.output.reviewList, id: \.reviewId) { item in
                            ReviewListCardView(
                                data: item
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
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
                Text("사용자 후기")
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

private extension ReviewView {
    
    struct ReviewListCardView: View {
        let data: ReviewResponseEntity
        @State var isExpanded: Bool = false
        
        var body: some View {
            VStack(alignment: .leading) {
                ReviewListMainContentView(
                    data: data,
                    isExpanded: $isExpanded)
            }
            .frame(maxWidth: .infinity)
            .background(.grayScale0)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
        
        
        
    }
    
    
    struct ReviewListMainContentView: View {
        
        let data: ReviewResponseEntity
        @Binding var isExpanded: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    ProfileImageView(image: nil, size: 32)
                    VStack(alignment: .leading, spacing: 0) {
                        StarRatingView(staticRating: data.rating)
                        Text(data.creator.nick + " | " + data.createdAt.toDisplayDate())
                            .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 8) {
                    if isExpanded {
                        Text(data.content)
                            .appFont(PretendardFontStyle.body2, textColor: .grayScale90)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(data.content)
                            .appFont(PretendardFontStyle.body2, textColor: .grayScale90)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                    
                    
                    if data.isTextOverThreeLines || !data.reviewImageUrls.isEmpty {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    isExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Text(isExpanded ? "접기" : "더보기")
                                        .appFont(PretendardFontStyle.body3, textColor: .blue)
                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                            .frame(height: 30)
                        }
                        
                    }
                    
                    if !data.reviewImageUrls.isEmpty {
                        if isExpanded {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(data.reviewImageUrls.enumerated()), id: \.offset) { index, imageUrl in
                                    RemoteImageView(path: imageUrl)
                                        .frame(height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .contentShape(Rectangle())
                                }
                            }
                            
                        } else {
                            HStack(spacing: 8) {
                                ForEach(Array(data.reviewImageUrls.prefix(3).enumerated()), id: \.offset) { index, imageUrl in
                                    ZStack {
                                        RemoteImageView(path: imageUrl)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        if index == 2 && data.reviewImageUrls.count > 3 {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.4))
                                                .frame(width: 80, height: 80)
                                            
                                            Text("+\(data.reviewImageUrls.count - 3)")
                                                .appFont(PretendardFontStyle.body2, textColor: .white)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(.grayScale0)
            .cornerRadius(12)
        }
        
        
    }
    
}

