//
//  ZoomableImageFullScreenView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import SwiftUI

struct ZoomableImageFullScreenView: View {
    let path: String
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero // 드래그 중 임시 오프셋
    @StateObject var viewModel: ZoomableImageFullScreenViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let image = viewModel.output.image {
                    imageView(image: image, geometry: geometry)
                } else {
                    loadingView
                }
            }
            .overlay(closeButton, alignment: .topTrailing)
        }
        .commonAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowingError },
                set: { isPresented in
                    if !isPresented {
                        dismiss()
                    }
                }
            ),
            title: viewModel.output.presentedError?.message.title,
            message: viewModel.output.presentedError?.message.msg
        )
        .onAppear {
            viewModel.action(.onAppearRequested(path: path))
        }
        .statusBarHidden()
    }
}

// MARK: - View Components
private extension ZoomableImageFullScreenView {
    
    func imageView(image: UIImage, geometry: GeometryProxy) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .scaleEffect(scale)
            .offset(
                x: offset.width + dragOffset.width,
                y: offset.height + dragOffset.height
            )
            .gesture(zoomAndPanGesture(geometry: geometry))
            .onTapGesture(count: 2, perform: handleDoubleTap)
    }
    
    var loadingView: some View {
        ProgressView("로딩 중...")
            .foregroundStyle(.white)
            .scaleEffect(1.2)
    }
    
    var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
            }
            Spacer()
        }
    }
}

// MARK: - Gestures
private extension ZoomableImageFullScreenView {
    
    func zoomAndPanGesture(geometry: GeometryProxy) -> some Gesture {
        SimultaneousGesture(
            // 확대/축소 제스처 (개선됨)
            MagnificationGesture()
                .onChanged { value in
                    let newScale = max(1.0, min(5.0, value))
                    scale = newScale
                    
                    // 확대/축소 시 오프셋 자동 조정
                    let boundedOffset = getBoundedOffset(
                        currentOffset: CGSize(
                            width: offset.width + dragOffset.width,
                            height: offset.height + dragOffset.height
                        ),
                        scale: newScale,
                        geometry: geometry
                    )
                    
                    offset = boundedOffset
                    dragOffset = .zero
                }
                .onEnded { value in
                    let finalScale = max(1.0, min(5.0, value))
                    
                    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
                        scale = finalScale
                        
                        // 확대/축소 완료 후 경계 체크
                        if finalScale == 1.0 {
                            offset = .zero
                            dragOffset = .zero
                        } else {
                            let boundedOffset = getBoundedOffset(
                                currentOffset: offset,
                                scale: finalScale,
                                geometry: geometry
                            )
                            offset = boundedOffset
                        }
                    }
                },
            
            // 드래그 제스처 (개선됨)
            DragGesture()
                .onChanged { value in
                    // 실시간으로 dragOffset 업데이트 (부드러운 드래그)
                    dragOffset = value.translation
                }
                .onEnded { value in
                    // 드래그 완료 시 최종 위치 계산
                    let finalOffset = CGSize(
                        width: offset.width + value.translation.width,
                        height: offset.height + value.translation.height
                    )
                    
                    let boundedOffset = getBoundedOffset(
                        currentOffset: finalOffset,
                        scale: scale,
                        geometry: geometry
                    )
                    
                    // 경계를 벗어났을 때만 애니메이션 적용
                    if boundedOffset.width != finalOffset.width || boundedOffset.height != finalOffset.height {
                        // 경계로 돌아가는 애니메이션
                        withAnimation(.easeOut(duration: 0.25)) {
                            offset = boundedOffset
                            dragOffset = .zero
                        }
                    } else {
                        // 경계 내에서는 애니메이션 없이 즉시 적용
                        offset = boundedOffset
                        dragOffset = .zero
                    }
                }
        )
    }
    
    // 경계 제한 계산 함수
    func getBoundedOffset(currentOffset: CGSize, scale: CGFloat, geometry: GeometryProxy) -> CGSize {
        if scale <= 1.0 {
            return .zero
        }
        
        // 이미지 실제 크기 계산
        let imageFrame = geometry.size
        let scaledWidth = imageFrame.width * scale
        let scaledHeight = imageFrame.height * scale
        
        // 최대 이동 가능 거리 계산
        let maxOffsetX = max(0, (scaledWidth - imageFrame.width) / 2)
        let maxOffsetY = max(0, (scaledHeight - imageFrame.height) / 2)
        
        return CGSize(
            width: max(-maxOffsetX, min(maxOffsetX, currentOffset.width)),
            height: max(-maxOffsetY, min(maxOffsetY, currentOffset.height))
        )
    }
    

}

// MARK: - Actions
private extension ZoomableImageFullScreenView {
    
    func handleDoubleTap() {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
            if scale > 1.0 {
                scale = 1.0
                offset = .zero
                dragOffset = .zero
            } else {
                scale = 2.0
                // 더블탭 시 중앙으로 이동
                offset = .zero
            }
        }
    }
}
