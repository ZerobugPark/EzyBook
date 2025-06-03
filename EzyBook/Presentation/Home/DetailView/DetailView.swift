//
//  DetailView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/2/25.
//

import SwiftUI
import AVKit

struct DetailView: View {
    
    //@Environment(\.displayScale) var scale
    //@EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: DetailViewModel
    //@ObservedObject  var coordinator: HomeCoordinator
    
    //private(set) var activityID: String
    

    let imageNames: [ImageResource] = [.test, .test, .test, .test]
    
    private var data: ActivityDetailEntity {
        viewModel.output.activityDetailInfo
    }
    
    @State private var selectedIndex = 0
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    ZStack(alignment: .top) {
                        makeTapImageView()
                        makeThumnailView()
                    }
                    VStack {
                        Text(viewModel.output.activityDetailInfo.description)
                            .appFont(PretendardFontStyle.caption1, textColor: .grayScale60)
                            .lineSpacing(4)
                    }
                    
                }
 
            }
            .background(.grayScale15)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButtonView {
                        
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ActivityKeepButtonView(isKeep: data.isKeep) {
                        print("좋아요")
                    }
                }
            }
            .onAppear {
                // viewModel.action(.onAppearRequested(id: activityID))
            }
        }
    }
    
    
}


/// 메인 섹션
extension DetailView {
    
    private func makeTapImageView() -> some View{
        ZStack(alignment: .bottom) {
            // 이미지 페이징
            TabView(selection: $selectedIndex) {
                ForEach(imageNames.indices, id: \.self) { index in
                    Image(imageNames[index])
                        .resizable()
                        .scaledToFill()
                        .tag(index)
                        .clipped()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // ✅ 기본 인디케이터 숨김
            .frame(height: 400)
            
            // 하단 오버레이 (텍스트 + 그라데이션 + 커스텀 인디케이터)
            VStack(spacing: 8) {
                makeIndicator()
                makeTitleSection()
                    
            }
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.grayScale60.opacity(0.05), location: 0.0),
                        .init(color: Color.grayScale60.opacity(0.15), location: 0.2),
                        .init(color: Color.clear, location: 1.0)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )

                .frame(height: 100)
                .edgesIgnoringSafeArea(.bottom)
            )
        }
    }
    
    private func makeIndicator() -> some View {
        // 커스텀 인디케이터
        HStack(spacing: 6) {
            ForEach(imageNames.indices, id: \.self) { index in
                if index == selectedIndex {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 30, height: 8)
                        .transition(.scale)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
                 
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
    }
    
    
    private func makeThumnailView() -> some View {
        
        VStack(spacing: 10) {
            ForEach(imageNames.indices, id: \.self) { index in
                let isSelected = index == selectedIndex
                
                Image(imageNames[index])
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 5)
                    )
                    .scaleEffect(isSelected ? 1.25 : 1.0) //
                    .shadow(color: isSelected ? Color.white.opacity(0.4) : .clear, radius: 8)
                    .padding(.vertical, isSelected ? 2 : 0) // 간격 유지용
                    .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                    .onTapGesture {
                        selectedIndex = index
                    }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(1.0))
        )
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 12)
    }
}

extension DetailView {
    private func makeTitleSection() -> some View {
        // 텍스트 정보
        VStack(alignment: .leading, spacing: 4) {
            Text(data.title)
                .appFont(PaperlogyFontStyle.title, textColor: .grayScale100)
            HStack(spacing: 10) {
                Text(data.country)
                    .appFont(PretendardFontStyle.body2, textColor: .grayScale0)
                ActivityPointMoneyLabel(pointReward: data.pointReward)
                ActivityKeepLabel(keepCount: data.keepCount)
                
                
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        
        
    }
}


#Preview {
    DetailView(viewModel: DetailViewModel())
}

