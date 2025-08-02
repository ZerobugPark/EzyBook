//
//  CommunityView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

enum PostFilter {
    
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
}

struct CommunityView: View {
    
    //@State private var selectedPost = false
    
    //@ObservedObject var coordinator: CommunityCoordinator
    
    @State var query: String = ""
    @State var isSearching: Bool = false
    @State var selectedFlag: Flag = .all
    @State var selectedFilter: Filter = .all
    @State var progress: CGFloat = 1.0
    @State var filter: PostFilter = .createdAt
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    FlagSelectionView(
                        selectedFlag: $selectedFlag) { flag in
                            
                        }
                    
                    FilterSelectionView(
                        selectedFilter: $selectedFilter) { filter in
                            
                        }
                    
                    activityProgressSection(filter: $filter)
                        .padding(20)
                }
                
                PostListCardView()
                    .padding(.horizontal, 20)
            }
            
            
            
            
            
            FloatingButton(text: "글쓰기") {
                
            }
            
            
            
        }
        .searchModify($query, $isSearching, "타이틀을 입력해주세요.")
        //        .sheet(isPresented: $selectedPost) {
        //            coordinator.makePostsView()
        //        }
    }
    
    
    
}

// MARK: ProgressBox

private extension CommunityView {
    @ViewBuilder
    func activityProgressSection(filter: Binding<PostFilter>) -> some View {
        
    
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("액티비티 포스트")
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale60)
                
                Spacer()
                
                /// Filter 버튼
                Button {
                    filter.wrappedValue = filter.wrappedValue == .createdAt ? .likes : .createdAt
                } label: {
                    HStack {
                        Image(.iconSort)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.blackSeafoam)
                        Text(filter.wrappedValue.text)
                            .appFont(PretendardFontStyle.body2, textColor: .blackSeafoam)
                    }
      
                }
            }

            ProgressBox(progress: $progress)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
     
    }
    
    struct ProgressBox: View {
        @Binding var progress: CGFloat

        var body: some View {
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .bottom) {
                    Text("Distance")
                        .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                    Text("\(Int(progress * 500))KM")
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
                            .frame(width: geometry.size.width * progress, height: 20)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.deepSeafoam, .blackSeafoam]), startPoint: .leading, endPoint: .trailing))
                        
                        
                        Circle()
                            .fill(Color.blackSeafoam)
                            .frame(width: 24, height: 24)
                            .offset(x: max(min(geometry.size.width * progress - 12, geometry.size.width - 12), -12))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let newProgress = max(0, min(1, value.location.x / geometry.size.width))
                                        self.progress = newProgress
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
        
        var body: some View {
            VStack(alignment: .leading) {
                PostListMainContentView()
            }
            .frame(maxWidth: .infinity)
            .background(.grayScale0)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        }

    }
    
    struct PostListMainContentView: View {
        let images: [UIImage] = [UIImage(systemName: "star.fill")!, UIImage(systemName: "star.fill")!, UIImage(systemName: "star.fill")!, UIImage(systemName: "star.fill")!, UIImage(systemName: "star.fill")!]
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(alignment: .center, spacing: 12) {
                    ProfileImageView(image: nil, size: 32)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("닉네임")
                            .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                        Text("작성 시간")
                            .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                            
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                PostImagesView(images: images)
                
                Text("액비티티 포스트 제목")
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
                
                Text("후기")
                    .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                
                PostTagView()
            }
            .padding(20)
            .background(.grayScale0)
            .cornerRadius(12)
        }
    }
    
    struct PostImagesView: View {
        let images: [UIImage]

        var body: some View {
            switch images.count {
            case 1:
                // 하나면 꽉 채우기
                Image(uiImage: images[0])
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)

            case 2:
                // 왼쪽 큰 이미지, 오른쪽은 세로로
                HStack(spacing: 8) {
                    Image(uiImage: images[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipped()
                        .cornerRadius(12)

                    Image(uiImage: images[1])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 200)
                        .clipped()
                        .cornerRadius(12)
                }

            case 3:
                // 왼쪽 큰 이미지, 오른쪽은 두 개 위아래
                HStack(spacing: 8) {
                    Image(uiImage: images[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipped()
                        .cornerRadius(12)

                    VStack(spacing: 8) {
                        Image(uiImage: images[1])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 96)
                            .clipped()
                            .cornerRadius(12)

                        Image(uiImage: images[2])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 96)
                            .clipped()
                            .cornerRadius(12)
                    }
                }
            case 4...:
                HStack(spacing: 8) {
                    Image(uiImage: images[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipped()
                        .cornerRadius(12)

                    VStack(spacing: 8) {
                        ForEach(1..<3, id: \.self) { index in
                            if index == 2 {
                                ZStack {
                                    Image(uiImage: images[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 96)
                                        .clipped()
                                        .cornerRadius(12)

                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 100, height: 96)

                                    Text("+\(images.count - 3)")
                                        .appFont(PretendardFontStyle.body2, textColor: .white)
                                }
                            } else {
                                Image(uiImage: images[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 96)
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
    }
    
    
    struct PostTagView: View {
        
        
        var body: some View {
            HStack {
                Label {
                    Text("국가")
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
                
                Text("액티비티 종류")
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

#Preview {
    CommunityView()
    
}
