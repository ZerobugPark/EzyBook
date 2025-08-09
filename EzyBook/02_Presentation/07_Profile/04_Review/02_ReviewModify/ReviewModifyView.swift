//
//  ReviewModifyView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/9/25.
//

import SwiftUI

struct ReviewModifyView: View {
    
    @Environment(\.dismiss) private var dismiss
  
    @FocusState private var isTextEditorFocused: Bool
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: ReviewModifyViewModel
    
    
    let onConfirm: (UserReviewDetailList?) -> Void
    
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
                    title: "리뷰 수정", leadingAction: {
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
                    title: "수정 완료",
                    isEnabled: isFormValid
                ) {
                    viewModel.action(.modifyReView)
                }
                
            }
            
            LoadingOverlayView(isLoading: isProcessingThumbnails)
        }
        .withCommonUIHandling(viewModel) { code, isSuccess in
            if isSuccess {
                onConfirm(viewModel.output.resultModifyReviewData)
                dismiss()
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
