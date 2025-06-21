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
    /// 어디까지 뷰모델에서 관리해줘야할까?
    @State private var rating = 0
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    @StateObject var viewModel = WriteReviewViewModel()
    
    @FocusState private var isTextEditorFocused: Bool
    
    //let ordercode: String
    
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
                makeNavigationBar()
                makePhotoSelectionView()
                makeReviewTextField()
                makeStarRatingView()
                Spacer()
                makeCompleteButton()
            }
        }
    }
    private func makeCompleteButton() -> some View {
        VStack {
            
            
            Button(action: {
                // 작성 완료 액션
                
                
            }) {
                Text("작성 완료")
                    .appFont(PaperlogyFontStyle.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .background(.grayScale0)
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
    
    private func makePhotoSelectionView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("사진 (최대 3장)")
                .appFont(PretendardFontStyle.body1)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // 사진 추가 버튼
                    if selectedImages.count < 3 {
                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: 3 - selectedImages.count,
                            matching: .images
                        ) {
                            VStack {
                                Image(systemName: "plus")
                                    .appFont(PretendardFontStyle.body1, textColor: .grayScale75)
                                Text("사진 추가")
                                    .appFont(PretendardFontStyle.body1, textColor: .grayScale75)
                            }
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                        }
                    }
                    
                    // 선택된 이미지들
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(10)
                            
                            // 삭제 버튼
                            Button(action: {
                                removeImage(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .offset(x: -3, y: 3)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .padding(20)
        .onChange(of: selectedPhotos) { newItems in
            loadImages(from: newItems)
        }
    }
    
    private func makeReviewTextField() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("리뷰")
                .appFont(PretendardFontStyle.body1)
            TextEditor(text: $viewModel.input.reviewText)
                .frame(height: 150) // Set the height for the text input area
                .cornerRadius(15) // 모서리 둥글게 하기
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
                .multilineTextAlignment(.center) // 혹은
            //.frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
    }
    
    // 이미지 로드 함수
    private func loadImages(from items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            if !selectedImages.contains(where: { $0.pngData() == uiImage.pngData() }) {
                                selectedImages.append(uiImage)
                            }
                        }
                    }
                case .failure(let error):
                    print("이미지 로드 실패: \(error)")
                }
            }
        }
    }
    
    // 이미지 삭제 함수
    private func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        
        // selectedPhotos도 동기화
        if index < selectedPhotos.count {
            selectedPhotos.remove(at: index)
        }
    }
}

#Preview {
    WriteReViewView()
}

