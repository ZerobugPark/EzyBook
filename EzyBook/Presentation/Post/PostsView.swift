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
    @State private var selectedMedia: [MediaItem] = []
    @State private var photosPickerItems: [PhotosPickerItem] = []
    @State private var title = ""
    @State private var description = ""
    @State private var category = "판매하기"
    @State private var showingImagePicker = false
    
    struct MediaItem: Identifiable {
        let id = UUID()
        let image: UIImage?
        let videoURL: URL?
        let isVideo: Bool
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 사진 업로드 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        if selectedMedia.isEmpty {
                            // 사진 추가 버튼
                            PhotosPicker(
                                selection: $photosPickerItems,
                                maxSelectionCount: 10,
                                matching: .any(of: [.images, .videos])
                            ) {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("0/10")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                        } else {
                            // 선택된 사진들 표시
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // 사진/동영상 추가 버튼
                                    if selectedMedia.count < 10 {
                                        PhotosPicker(
                                            selection: $photosPickerItems,
                                            maxSelectionCount: 10 - selectedMedia.count,
                                            matching: .any(of: [.images, .videos])
                                        ) {
                                            VStack(spacing: 4) {
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.gray)
                                                Text("\(selectedMedia.count)/10")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(width: 80, height: 80)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    // 선택된 미디어들
                                    ForEach(Array(selectedMedia.enumerated()), id: \.offset) { index, mediaItem in
                                        ZStack {
                                            if let image = mediaItem.image {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80)
                                                    .clipped()
                                                    .cornerRadius(8)
                                            }
                                            
                                            // 동영상 아이콘 표시
                                            if mediaItem.isVideo {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.3))
                                                    .clipShape(Circle())
                                            }
                                        }
                                        .overlay(
                                            Button(action: {
                                                selectedMedia.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.6))
                                                    .clipShape(Circle())
                                                    .font(.system(size: 16))
                                            }
                                            .padding(4),
                                            alignment: .topTrailing
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // 제목 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("제목")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 20)
                        
                        TextField("글 제목", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                    }
                    
                    // 자세한 설명
                    VStack(alignment: .leading, spacing: 8) {
                        Text("자세한 설명")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 20)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    
                    // 자주 쓰는 문구 버튼
                    Button(action: {
                        // 자주 쓰는 문구 액션
                    }) {
                        Text("자주 쓰는 문구")
                            .font(.system(size: 14))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    
                    // 거래 방식
                    VStack(alignment: .leading, spacing: 12) {
                        Text("거래 방식")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                category = "판매하기"
                            }) {
                                Text("판매하기")
                                    .font(.system(size: 14))
                                    .foregroundColor(category == "판매하기" ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(category == "판매하기" ? Color.black : Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                            }
                            
                            Button(action: {
                                category = "나눠하기"
                            }) {
                                Text("나눠하기")
                                    .font(.system(size: 14))
                                    .foregroundColor(category == "나눠하기" ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(category == "나눠하기" ? Color.black : Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("게시글 등록하기")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                // 작성 완료 버튼
                VStack {
                    Spacer()
                    Button(action: {
                        // 작성 완료 액션
                    }) {
                        Text("작성 완료")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
            )
        }
        .onChange(of: photosPickerItems) { items in
            Task {
                // items가 비어있으면 아무것도 하지 않음 (취소한 경우)
                guard !items.isEmpty else { return }
                
                for item in items {
                    // 이미지 먼저 시도
                    if let imageData = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: imageData) {
                        await MainActor.run {
                            let mediaItem = MediaItem(image: image, videoURL: nil, isVideo: false)
                            selectedMedia.append(mediaItem)
                        }
                    }
                    // 동영상 시도 (URL로 직접 로드)
                    else {
                        // 임시로 기본 동영상 아이콘 사용
                        await MainActor.run {
                            let defaultVideoImage = UIImage(systemName: "video.fill") ?? UIImage()
                            let mediaItem = MediaItem(image: defaultVideoImage, videoURL: nil, isVideo: true)
                            selectedMedia.append(mediaItem)
                        }
                    }
                }
                
                await MainActor.run {
                    photosPickerItems.removeAll()
                }
            }
        }
    }
    
    // 동영상 썸네일 생성 함수 (async로 변경)
    @MainActor
    private func generateThumbnail(for url: URL) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTime.zero)]) { _, cgImage, _, _, _ in
                if let cgImage = cgImage {
                    let thumbnail = UIImage(cgImage: cgImage)
                    continuation.resume(returning: thumbnail)
                } else {
                    // 기본 동영상 아이콘
                    continuation.resume(returning: UIImage(systemName: "video.fill"))
                }
            }
        }
    }
}

// Movie 타입 정의
struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie.mov")
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}
#Preview {
    PostsView()
}
