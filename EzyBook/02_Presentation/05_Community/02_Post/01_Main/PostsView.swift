//
//  PostsView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//


import SwiftUI
import PhotosUI
import AVFoundation

struct PostsView: View {
    @State private var aiEnabled = true
    
    @State private var photosPickerItems: [PhotosPickerItem] = []
    @State private var country = ""
    @State private var catrgory = ""
    @State private var showingImagePicker = false
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedMedia: [PickerSelectedMedia] = []
    @ObservedObject var coordinator: CommunityCoordinator
    @State var selectedActivity = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                ActivitySelectView(country: $country, catrgory: $catrgory) {
                    selectedActivity = true
                 }
                
                // 제목 입력
                VStack(alignment: .leading, spacing: 8) {
                    Text("제목")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 20)
//                    
//                    TextField("글 제목", text: $title)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.horizontal, 20)
                }
                
                // 자세한 설명
                VStack(alignment: .leading, spacing: 8) {
                    Text("후기")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 20)
                    
//                    TextEditor(text: $description)
//                        .frame(minHeight: 120)
//                        .padding(4)
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                        .padding(.horizontal, 20)
                }
                
                MediaPickerView(
                    mediaType: .all,
                    maxImageCount: 5,
                    selectedMedia: $selectedMedia
                )
                
                
                Spacer(minLength: 100)
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
                    Text("게시글 작성")
                        .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
                }
            }
            .fullScreenCover(isPresented: $selectedActivity) {
                coordinator.makeMyActivityView { orderList in
                    country = orderList.country
                    catrgory = orderList.category
                    
                }
            }
            

        }
    }
    
}

private extension PostsView {
    
    struct ActivitySelectView: View {
        
        @Binding var country: String
        @Binding var catrgory: String
        @State var title: String = "투어를 선택해주세요"
        var onTap: () -> (Void)
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("액비티비 선택")
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                
                Button {
                    onTap()
                } label: {
                    HStack(spacing: 12) {
                        Text(title)
                            .appFont(PretendardFontStyle.body1, textColor: .grayScale60)
                        Spacer()
                        Image(.iconChevron)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.grayScale60)
                            .rotationEffect(.degrees(180))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // ✅ 전체 너비
                }
                .padding(.horizontal, 20)
                
                HStack {
                    Text("국가:" + country)
                        .appFont(PretendardFontStyle.body2, textColor: .grayScale90)
                    Text("카테고리:" + catrgory)
                        .appFont(PretendardFontStyle.body2, textColor: .grayScale90)
                }
            }
        }
    }
    
}



