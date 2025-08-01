//
//  CommunityView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct CommunityView: View {
    
    //@State private var selectedPost = false
    
    //@ObservedObject var coordinator: CommunityCoordinator
    
    @State var query: String = ""
    @State var isSearching: Bool = false
    @State var selectedFlag: Flag = .all
    @State var selectedFilter: Filter = .all
    @State var progress: CGFloat = 1.0
    
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
                    
                    activityProgressSection()
                }
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
    func activityProgressSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("액티비티 포스트")
                .appFont(PaperlogyFontStyle.caption, textColor: .grayScale60)
            ProgressBox(progress: $progress)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
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
                        
                        // 슬라이드 핸들 (선택)
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


#Preview {
    CommunityView()
    
}
