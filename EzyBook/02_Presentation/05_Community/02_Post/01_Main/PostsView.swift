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
    
    @State private var selectedMedia: [PickerSelectedMedia] = []
    @ObservedObject var coordinator: CommunityCoordinator
    
    /// 이것도 코디네이터가 가지고 있어야하나?
    @State var selectedActivity = false // 화면전환 트리거
    @EnvironmentObject var appState: AppState
    @FocusState private var isTextEditorFocused: Bool
    
    @StateObject var viewModel: PostViewModel
    
    @State private var isProcessingThumbnails: Bool = false
    
    var body: some View {
        ZStack {
            
            // 키보드 해제용 투명 뷰
            if isTextEditorFocused {
                Rectangle()
                    .foregroundColor(.clear) // 시각적으로는 보이지 않지만
                    .contentShape(Rectangle()) // 터치 이벤트 영역 지정
                    .onTapGesture {
                        isTextEditorFocused = false // 포커스 해제 → 키보드 내려감
                    }
                    .ignoresSafeArea() // 화면 전체 덮게
                    .zIndex(1) // ScrollView 위에 올라오도록 보장
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    ActivitySelectView(country: viewModel.output.country, catrgory: viewModel.output.catrgory, title: viewModel.output.activityTitle) {
                        selectedActivity = true
                    }
                    .padding(.top, 16)
                    
                    PostContentView(
                        title: $viewModel.title,
                        content: $viewModel.content,
                        isTextEditorFocused: $isTextEditorFocused
                    )
                    
                    MediaPickerView(
                        mediaType: .all,
                        maxImageCount: 5,
                        selectedMedia: $selectedMedia,
                        isProcessingThumbnails: $isProcessingThumbnails
                    )
                    
                    
                    PrimaryActionButton(
                        title: "작성하기",
                        isEnabled: viewModel.isConfirm
                    ) {
                        viewModel.action(
                            .writePost(
                                images: selectedMedia.filter { $0.type == .image }.compactMap { $0.image },
                                videos: selectedMedia.filter { $0.type == .video } .compactMap { $0.videoURL }
                            )
                        )
                    }
                    
                }
            }
            .disabled(viewModel.output.isLoading)
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading || isProcessingThumbnails)
            
 
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
                viewModel.action(.acitivitySelected(activity: orderList))
            }
        }
        .withCommonUIHandling(viewModel) { code, isSuccess in
            if isSuccess {
                coordinator.pop()
            } else if code == 418 {
                appState.isLoggedIn = false
            }
        }
    }
    
}

private extension PostsView {
    
    struct ActivitySelectView: View {
        
        var country: String
        var catrgory: String
        var title: String
        
        var onTap: () -> (Void)
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("액비티비 선택")
                    .appFont(PretendardFontStyle.body1)
                
                Button {
                    onTap()
                } label: {
                    HStack(alignment: .center ,spacing: 12) {
                        Text(title)
                            .appFont(PretendardFontStyle.body1, textColor: .grayScale60)
                            .lineLimit(1)
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
                
                
                if !country.isEmpty && !catrgory.isEmpty {
                    HStack(alignment: .center, spacing: 10) {
                        Text("국가: " + country)
                            .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
                        Text("카테고리: " + catrgory)
                            .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
                    }
                }
                
            }
            .padding(.horizontal, 20)
        }
    }
    
    
    struct PostContentView: View {
        
        @Binding var title: String
        @Binding var content: String
        var isTextEditorFocused: FocusState<Bool>.Binding
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 16) {
                Text("제목")
                    .appFont(PretendardFontStyle.body1)
                TextEditor(text: $title)
                    .frame(height: 40)
                    .focused(isTextEditorFocused)
                    .overlay(
                          RoundedRectangle(cornerRadius: 15)
                              .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                      )
                    
                
                Text("후기")
                    .appFont(PretendardFontStyle.body1)
                
                TextEditor(text: $content)
                    .frame(height: 150) // Set the height for the text input area
                    .focused(isTextEditorFocused)
                    .overlay(
                          RoundedRectangle(cornerRadius: 15)
                              .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                      )
            }
            .padding(.horizontal, 20)
            
     
        }
        
    }
    
}



