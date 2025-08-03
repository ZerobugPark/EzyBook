//
//  CommunityView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

enum PostSort {
    
    case createdAt
    case likes
    
    var text: String {
        switch self {
        case .createdAt:
            "최신순"
        case .likes:
            "좋아요"
        }
    }
    
    var orderBy: String{
        switch self {
        case .createdAt:
            "createdAt"
        case .likes:
            "likes"
        }
    }
}

struct CommunityView: View {
    
    @State private var selectedPost = false
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: CommunityViewModel
    @ObservedObject var coordinator: CommunityCoordinator
    
    

    @State var isSearching: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                
       
                    VStack {
                        FlagSelectionView(
                            selectedFlag: $viewModel.selectedFlag) { flag in
                                viewModel.action(.selectionChanged(flag: flag, filter: viewModel.selectedFilter))
                            }
                        
                        FilterSelectionView(
                            selectedFilter: $viewModel.selectedFilter) { filter in
                                viewModel.action(.selectionChanged(flag: viewModel.selectedFlag, filter: filter))
                            }
                        
                        
                        activityProgressSection(sort: viewModel.postSort, distance: $viewModel.distance) {
                            viewModel.action(.sortButtonTapped)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 20)
                        
                        if viewModel.output.postList.isEmpty {
                            Spacer()
                            Text("검색 결과가 없습니다..")
                                .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            Spacer()
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(viewModel.output.postList.enumerated()), id:\.element.id) { index, data in
                                    PostListCardView(data: data) {
                                        coordinator.push(.detailView(postID: data.postID))
                                    }
                                        .onAppear { viewModel.action(.paginationPostList(index: index)) }
                                }
                               
                            }
                            .padding(.horizontal, 15)
                        }
                    }
               
  
                
            }
            .disabled(viewModel.output.isLoading)
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
            
            FloatingButton(text: "글쓰기") {
                coordinator.push(.postView)
            }
            
            
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TitleTextView(title: "커뮤니티")
            }
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .searchModify($viewModel.input.query, $isSearching, "타이틀을 입력해주세요.")
        .onTapGesture {
            hideKeyboard()
            isSearching = false
        }
        .onSubmit(of: .search, {
            viewModel.action(.searchButtonTapped)
            isSearching = false
        })
    }
    
    
    
}

// MARK: ProgressBox

private extension CommunityView {
    @ViewBuilder
    func activityProgressSection(sort: PostSort, distance: Binding<CGFloat>,onTapped: @escaping () -> Void) -> some View {
        
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("액티비티 포스트")
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale60)
                
                Spacer()
                
                /// Filter 버튼
                Button {
                    onTapped()
                } label: {
                    HStack {
                        Image(.iconSort)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.blackSeafoam)
                        Text(sort.text)
                            .appFont(PretendardFontStyle.body2, textColor: .blackSeafoam)
                    }
                    
                }
            }
            
            ProgressBox(distance: distance)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    struct ProgressBox: View {
        @Binding var distance: CGFloat
        
        var body: some View {
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .bottom) {
                    Text("Distance")
                        .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                    Text(String(format: "%.1fKM", distance * 50))
                        .appFont(PretendardFontStyle.body1, textColor: .blackSeafoam)
                    Spacer()
                    
                    
                }
                .frame(maxWidth: .infinity)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 20)
                            .foregroundStyle(.grayScale45)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: geometry.size.width * distance, height: 20)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.deepSeafoam, .blackSeafoam]), startPoint: .leading, endPoint: .trailing))
                        
                        
                        Circle()
                            .fill(Color.blackSeafoam)
                            .frame(width: 24, height: 24)
                            .offset(x: max(min(geometry.size.width * distance - 12, geometry.size.width - 12), -12))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let newProgress = max(0, min(1, value.location.x / geometry.size.width))
                                        self.distance = newProgress
                                    }
                            )
                    }
                }
                .frame(height: 20) // GeometryReader 높이 고정
                
                
                
            }
            .padding(20)
            .background(.white, in: .rect(cornerRadius: 10))
            .shadow(color: .black.opacity(0.1), radius: 10, x:0.0, y: 0.0)
            
        }
        
    }
    
    
}

private extension CommunityView {
    
    
    
    struct PostListCardView: View {
        
        let data: PostSummaryEntity
        let onTap: () -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                PostListMainContentView(data: data)
            }
            .frame(maxWidth: .infinity)
            .background(.grayScale0)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        }
        
    }
    
    struct PostListMainContentView: View {
        
        let data:PostSummaryEntity
        
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(alignment: .center, spacing: 12) {
                    ProfileImageView(path: data.creator.profileImage, size: 32)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(data.creator.nick)
                            .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                        Text(data.relativeTimeDescription)
                            .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                        
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                if !data.files.isEmpty {
                    PostImagesView(paths: data.files)
                }
                
                
                Text(data.title)
                    .lineLimit(1)
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
                
                Text(data.content)
                    .lineLimit(2)
                    .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                
                PostTagView(country: data.country, category: data.category)
            }
            .padding(20)
            .background(.grayScale0)
            .cornerRadius(12)
        }
    }
    
    struct PostImagesView: View {
        let paths: [String]

        var body: some View {
            GeometryReader { geo in
                switch paths.count {
                case 1:
                    RemoteImageView(path: paths[0])
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.width * 0.5)
                        .clipped()
                        .cornerRadius(12)
                case 2:
                    HStack(spacing: 8) {
                        RemoteImageView(path: paths[0])
                            .scaledToFill()
                            .frame(width: geo.size.width * 0.5 - 4, height: geo.size.width * 0.5)
                            .clipped()
                            .cornerRadius(12)
                        
                        RemoteImageView(path: paths[1])
                            .scaledToFill()
                            .frame(width: geo.size.width * 0.5 - 4, height: geo.size.width * 0.5)
                            .clipped()
                            .cornerRadius(12)
                    }
                case 3:
                    HStack(spacing: 8) {
                        RemoteImageView(path: paths[0])
                            .scaledToFill()
                            .frame(width: geo.size.width * 0.6 - 4, height: geo.size.width * 0.5)
                            .clipped()
                            .cornerRadius(12)
                        
                        VStack(spacing: 8) {
                            RemoteImageView(path: paths[1])
                                .scaledToFill()
                                .frame(width: geo.size.width * 0.4 - 4, height: geo.size.width * 0.25 - 4)
                                .clipped()
                                .cornerRadius(12)
                            
                            RemoteImageView(path: paths[2])
                                .scaledToFill()
                                .frame(width: geo.size.width * 0.4 - 4, height: geo.size.width * 0.25 - 4)
                                .clipped()
                                .cornerRadius(12)
                        }
                    }
                case 4...:
                    HStack(spacing: 8) {
                        RemoteImageView(path: paths[0])
                            .scaledToFill()
                            .frame(width: geo.size.width * 0.6 - 4, height: geo.size.width * 0.5)
                            .clipped()
                            .cornerRadius(12)
                        
                        VStack(spacing: 8) {
                            ForEach(1..<3, id: \.self) { index in
                                if index == 2 {
                                    ZStack {
                                        RemoteImageView(path: paths[index])
                                            .scaledToFill()
                                            .frame(width: geo.size.width * 0.4 - 4, height: geo.size.width * 0.25 - 4)
                                            .clipped()
                                            .cornerRadius(12)
                                        
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black.opacity(0.4))
                                            .frame(width: geo.size.width * 0.4 - 4, height: geo.size.width * 0.25 - 4)
                                        
                                        Text("+\(paths.count - 3)")
                                            .appFont(PretendardFontStyle.body2, textColor: .white)
                                    }
                                } else {
                                    RemoteImageView(path: paths[index])
                                        .scaledToFill()
                                        .frame(width: geo.size.width * 0.4 - 4, height: geo.size.width * 0.25 - 4)
                                        .clipped()
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                default:
                    EmptyView()
                }
            }
            .frame(height: 180)
        }
    }
    
    
    struct PostTagView: View {
        
        let country: String
        let category: String
        
        var body: some View {
            HStack {
                Label {
                    Text(country)
                        .appFont(PretendardFontStyle.body3, textColor: .deepSeafoam)
                } icon: {
                    Image(.iconLocation)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.deepSeafoam)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.deepSeafoam, lineWidth: 1)
                )
                
                Text(category)
                    .appFont(PretendardFontStyle.body3, textColor: .deepSeafoam)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.deepSeafoam, lineWidth: 1)
                    )
                
                
                
                
            }
        }
        
        
    }
    
}
