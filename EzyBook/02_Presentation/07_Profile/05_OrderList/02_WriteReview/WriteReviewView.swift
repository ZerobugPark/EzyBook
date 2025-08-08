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
  
    
    @FocusState private var isTextEditorFocused: Bool
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: WriteReviewViewModel
    
    
      let onConfirm: () -> Void
    
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
                    selectedMedia: $viewModel.selectedMedia,
                    isProcessingThumbnails: $isProcessingThumbnails
                )
                
                ReviewTextField(
                    reviewText: $viewModel.reviewText,
                    isFocused: $isTextEditorFocused
                )
                
                
                ReviewRating(rating: $viewModel.reviewRating)

                Spacer()
                
                PrimaryActionButton(
                    title: "작성 완료",
                    isEnabled: isFormValid
                ) {
                    viewModel.action(.writeReView)
                }
                
            }
            
            LoadingOverlayView(isLoading: isProcessingThumbnails)
        }
        .withCommonUIHandling(viewModel) { code, isSuccess in
            if isSuccess {
                
                NotificationCenter.default.post(name: .updatedProfileSupply, object: nil)
                onConfirm()
               
            } else if code == 418 {
                appState.isLoggedIn = false
            }
        }
    }
    

    // 폼 유효성 검사
    private var isFormValid: Bool {
        return !viewModel.reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.reviewRating > 0
    }
    
    
}

struct ReviewTextField: View {
    
    @Binding var reviewText: String
    let isFocused: FocusState<Bool>.Binding
    
    var body: some View {
     
        VStack(alignment: .leading, spacing: 10) {
            Text("리뷰")
                .appFont(PretendardFontStyle.body1)
            TextEditor(text: $reviewText)
                .frame(height: 150) // Set the height for the text input area
                .border(Color.grayScale60.opacity(0.5), width: 1) // 테두리 추가
                .focused(isFocused)
        }
        .padding(20)
    }
        
}


struct ReviewRating: View {
    
    @Binding var rating: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("별점")
                .appFont(PretendardFontStyle.body1)
            
            StarRatingView(rating: $rating)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
    
        }
        .padding(20)
    }
    
    
}
    



