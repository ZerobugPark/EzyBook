//
//  MediaPickerView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/27/25.
//
//   리뷰용 주석 추가
//  - 이미지/비디오 선택 및 삭제를 위한 공통 컴포넌트
//  - SRP 원칙 준수: UI(View)와 로직(MediaPickerLogic) 분리
//  - 애니메이션 및 쿨다운 동기화 (animationDuration)
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers


/// 선택된 미디어(이미지/비디오)를 통합 관리하는 모델
struct PickerSelectedMedia: Identifiable, Equatable {
    let id = UUID()
    let type: MediaPickerView.MediaType
    let image: UIImage?
    let videoURL: URL?
}


/// 이미지/비디오 선택 및 썸네일 표시를 담당하는 SwiftUI View
/// - mediaType: 이미지 전용/비디오 전용/혼합 지원
/// - maxImageCount: 최대 이미지 선택 수 제한
/// - selectedMedia: 부모 뷰에서 바인딩 (뷰모델 등과 연동)
struct MediaPickerView: View {
    enum MediaType {
        case image
        case video
        case all
    }
    
    
    let mediaType: MediaType
    let maxImageCount: Int
    @Binding var selectedMedia: [PickerSelectedMedia]
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @Binding var isProcessingThumbnails: Bool
    @State private var isDeleteLocked = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            makeTitle()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    makeAddButton()
                    makeSelectedMedia()
                }
                .padding(.horizontal, 5)
                
            }
            
        }
        .padding(20)
        .onChange(of: selectedItems) { newItems in
            loadSelectedMedia(from: newItems)
        }
    }
}

private extension MediaPickerView {
    
    private var animationDuration: Double { 0.25 }
    @ViewBuilder
    func makeTitle() -> some View {
        Text(mediaType == .image
             ? "사진 (최대 \(maxImageCount)장)"
             : mediaType == .video
             ? "동영상 선택"
             : "사진/동영상 선택")
        .font(.headline)
    }
    
    ///  추가 버튼 (이미지, 비디오, 혼합 선택 지원)
    @ViewBuilder
    func makeAddButton() -> some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: max(0, maxImageCount - selectedMedia.count),
            matching: mediaType == .all
            ? .any(of: [.images, .videos])
            : (mediaType == .image ? .images : .videos)
        ) {
            VStack {
                Image(systemName: "plus")
                    .foregroundColor(selectedMedia.count >= maxImageCount ? .gray.opacity(0.3) : .gray)
                Text("추가")
                    .font(.caption)
                    .foregroundColor(selectedMedia.count >= maxImageCount ? .gray.opacity(0.3) : .gray)
            }
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
        .disabled(selectedMedia.count >= maxImageCount)
    }
    
    /// 선택된 미디어 썸네일 표시 및 삭제 버튼 (overlay 사용)
    @ViewBuilder
    func makeSelectedMedia() -> some View {
        ForEach(selectedMedia) { item in
            ZStack(alignment: .topTrailing) {
                if item.type == .image, let img = item.image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(10)
                } else if item.type == .video, let url = item.videoURL {
                    VideoThumbnailView(videoURL: url)
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                }
            }
            .overlay(
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.red)
                    .background(Color.white)
                    .clipShape(Circle())
                    .padding(5),
                alignment: .topTrailing
            )
            .onTapGesture {
                print("Delete tapped for id: \(item.id)")
                removeMedia(item.id)
            }
        }
    }
}

private extension MediaPickerView {
    /// 미디어 삭제 로직 (쿨다운 및 애니메이션 동기화)
    func removeMedia(_ id: UUID) {
        guard !isDeleteLocked else { return }
        isDeleteLocked = true
        
        withAnimation(.easeInOut(duration: animationDuration)) {
            MediaPickerLogic.removeMedia(id, from: &selectedMedia)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isDeleteLocked = false
        }
    }
    
    ///  PhotosPicker로부터 비동기적으로 이미지/비디오 로드
    func loadSelectedMedia(from items: [PhotosPickerItem]) {
        Task {
            await MainActor.run {
                isProcessingThumbnails = true
            }
            let movieTypes: [UTType] = [.movie, .quickTimeMovie]
            await withTaskGroup(of: Void.self) { group in
                for item in items {
                    let types = item.supportedContentTypes.map { $0.identifier }
                    print("📸 Supported Content Types: \(types)")
                    
                    group.addTask {
                        if mediaType != .video,
                           let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                MediaPickerLogic.appendImage(image, to: &selectedMedia)
                            }
                        } else if mediaType != .image,
                                  item.supportedContentTypes.contains(where: { movieTypes.contains($0) }),
                                  let data = try? await item.loadTransferable(type: Data.self) {
                                    /// 비디오 타입 자체를 저장하면, 섬네일이 생기지 않아서, 데이터 형태로 변환 후 저장
                            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                            try? data.write(to: tempURL)
                            print("🎞 Video saved to: \(tempURL)")
                            await MainActor.run {
                                MediaPickerLogic.appendVideo(tempURL, to: &selectedMedia)
                            }
                        }
                    }
                }
            }
            await MainActor.run {
                isProcessingThumbnails = false
                selectedItems.removeAll()
            }
        }
    }
}

private extension MediaPickerView {
    // MARK: - MediaPickerLogic Helper
    
    /// 미디어 추가/삭제 로직 (테스트 가능하도록 별도 분리)
    private struct MediaPickerLogic {
        static func appendImage(_ image: UIImage, to selectedMedia: inout [PickerSelectedMedia]) {
            if !selectedMedia.contains(where: { $0.image?.pngData() == image.pngData() }) {
                selectedMedia.append(PickerSelectedMedia(type: .image, image: image, videoURL: nil))
            }
        }
        
        static func appendVideo(_ url: URL, to selectedMedia: inout [PickerSelectedMedia]) {
            if !selectedMedia.contains(where: { $0.videoURL == url }) {
                selectedMedia.append(PickerSelectedMedia(type: .video, image: nil, videoURL: url))
            }
        }
        
        static func removeMedia(_ id: UUID, from selectedMedia: inout [PickerSelectedMedia]) {
            selectedMedia.removeAll { $0.id == id }
        }
    }
}



// MARK: 비디오 미리보기용
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL
    
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .task {
            thumbnail = await generateThumbnail(from: videoURL)
        }
    }
    
    private func generateThumbnail(from url: URL) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let asset = AVAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                
                if let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) {
                    continuation.resume(returning: UIImage(cgImage: cgImage))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
