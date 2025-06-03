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
    
    //@StateObject var viewModel: DetailViewModel
    //@ObservedObject  var coordinator: HomeCoordinator
    
    //    /private(set) var activityID: String
    
    
    
    let images = ["star", "heart", "star.fill", "heart.fill"]
    @State private var selectedIndex = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
            
                ZStack(alignment: .bottom) {
                    // 이미지 페이징
                    TabView(selection: $selectedIndex) {
                        ForEach(images.indices, id: \.self) { index in
                            Image(systemName: images[index])
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
 
                        // ✅ 커스텀 인디케이터
                        HStack(spacing: 6) {
                            ForEach(images.indices, id: \.self) { index in
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
                        
                        // 텍스트 정보
                        VStack(alignment: .leading, spacing: 4) {
                            Text("겨울 새싹 스키 원정대")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                            HStack(spacing: 4) {
                                Text("스위스 융프라우")
                                Text("• 200P")
                                Text("⭐️ 4.8 (211)")
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.grayScale60.opacity(0.35), location: 0.0),
                                .init(color: Color.grayScale60.opacity(0.15), location: 0.2),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )

                        .frame(height: 200)
                        .edgesIgnoringSafeArea(.bottom)
                    )
                }
                
                
                
                VStack(spacing: 10) {
                    ForEach(images.indices, id: \.self) { index in
                        let isSelected = index == selectedIndex
                        
                        Image(systemName: images[index])
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
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButtonView {

                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ActivityKeepButtonView(isKeep: false) {
                        print("좋아요")
                    }
                }
            }
        }
    }
    
    
}





#Preview {
    DetailView()
}

