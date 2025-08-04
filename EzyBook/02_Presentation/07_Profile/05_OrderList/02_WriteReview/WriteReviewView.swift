//
//  WriteReViewView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/20/25.
//

import SwiftUI
import PhotosUI

struct WriteReViewView: View {
    
    @Environment(\.dismiss) private var dismiss
  
    @State private var rating = 0
    @State private var selectedMedia: [PickerSelectedMedia] = []
    

    let onConfirm: (String, Int) -> Void
    
    @FocusState private var isTextEditorFocused: Bool
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: WriteReviewViewModel
    @State private var isProcessingThumbnails: Bool = false
    
    var body: some View {
        ZStack {
            // 키보드 해제용 배경 (키보드가 올라왔을 때만)
            // 투명한 뷰를 뒤에 배치해서 버튼이 눌릴 수 있게 해줌
            if isTextEditorFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTextEditorFocused = false
                    }
                    .zIndex(-1) // 다른 뷰들보다 뒤에 배치
            }
            VStack(spacing: 0) {
                CommonNavigationBar(
                    title: "리뷰 작성", leadingAction: {
                        dismiss()
                    })
                
                
                MediaPickerView(
                    mediaType: .image,
                    maxImageCount: 5,
                    selectedMedia: $selectedMedia,
                    isProcessingThumbnails: $isProcessingThumbnails
                )
                
                makeReviewTextField()
                makeStarRatingView()
                Spacer()
                
                PrimaryActionButton(
                    title: "작성 완료",
                    isEnabled: isFormValid
                ) {
                    viewModel.action(
                        .writeReView(
                            images: selectedMedia.filter { $0.type == .image }.compactMap { $0.image },
                            rating: rating
                        )
                    )
                }
                
            }
            
            LoadingOverlayView(isLoading: isProcessingThumbnails)
        }
        .withCommonUIHandling(viewModel) { code, isSuccess in
            if isSuccess {
                onConfirm(viewModel.orderCode, rating)
                dismiss()
            } else if code == 418 {
                appState.isLoggedIn = false
            }
        }
    }
    

    // 폼 유효성 검사
    private var isFormValid: Bool {
        return !viewModel.input.reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && rating > 0
    }
    
    
}

extension WriteReViewView {
    
    private func makeNavigationBar() -> some View {
        HStack(alignment: .center) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("리뷰 작성")
                .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
            
            Spacer()
            
            // 균형을 맞추기 위한 투명한 버튼
            Button(action: {}) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .disabled(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.white)
    }
    
    
    private func makeReviewTextField() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("리뷰")
                .appFont(PretendardFontStyle.body1)
            TextEditor(text: $viewModel.input.reviewText)
                .frame(height: 150) // Set the height for the text input area
                .border(Color.grayScale60.opacity(0.5), width: 1) // 테두리 추가
                .focused($isTextEditorFocused)
        }
        .padding(20)
    }
    
    private func makeStarRatingView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("별점")
                .appFont(PretendardFontStyle.body1)
            
            StarRatingView(rating: $rating)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            //.frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
    }
    
}


