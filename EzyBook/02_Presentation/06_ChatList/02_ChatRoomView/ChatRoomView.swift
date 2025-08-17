//
//  ChatRoomView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//
import SwiftUI



struct MessageInputAction {
    let onSendTapped: () -> Void
    let onPhotoPicked: () -> Void
    let onFilePicked: () -> Void
}


// MARK: - 메인 채팅 뷰
struct ChatRoomView: View {
    
    struct PreviewItem: Identifiable {
        let id = UUID()
        let path: String
        
    }
    
    @StateObject var viewModel: ChatRoomViewModel
    private let onBack: () -> Void
    
    @State private var height: CGFloat = 40
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var container: AppDIContainer
    
    /// 화면전환 트리거
    @State var isImagePickerTapped: Bool = false
    @State var isFilePickerTapped: Bool = false
    @State var imageTapped: PreviewItem?
    @State var fileTapped: PreviewItem?
    @State private var showNewMessageToast = false
    
    @State private var didAutoScrollOnce: Bool = false
    
    init(viewModel: ChatRoomViewModel, onBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 채팅 메시지 리스트
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        Color.clear
                            .frame(height: 10)
                            .id("ScrollBottomPadding")
                            .scaleEffect(y: -1)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.output.groupedChatList.reversed(), id: \.date) { group in
                                ForEach(group.messages.reversed(), id: \.chatID) { message in
                                    MessageView(message: message) { path in
                                        handleImageTap(path: path)
                                    } onFileTap: { path in
                                        handleFileTap(path: path)
                                    }
                                    .id(message.chatID)
                                    .scaleEffect(y: -1)
                                }
                                
                                dateDivider(for: group.date)
                                    .scaleEffect(y: -1)
                            }
                            Color
                                .clear
                                .frame(height: 1)
                                .onAppear {
                                    viewModel.action(.loadChatList)
                                }
                                
                        }
                        .padding(.vertical, 12)
                    }
                    .scaleEffect(y: -1)
                    // 초기 데이터 로딩이 완료되었을 때 호출
                    .onChange(of: viewModel.output.groupedChatList.reduce(0) { $0 + $1.messages.count }) { total in
                        // Run only once after the very first batch arrives
                        guard !didAutoScrollOnce else { return }
                        guard total > 0, !viewModel.output.newMessage else { return }
                        
                        didAutoScrollOnce = true
                        scrollToBottom(proxy: proxy)
                    }
                    
                    
                    .onChange(of: viewModel.output.newMessage) { isNew in
                        if isNew {
                            showNewMessageToast = true
                        }
                    }
                    .onChange(of: viewModel.selectedImages.count) { _ in
                        //  이미지가 선택되면 채팅 목록을 위로 살짝 올리기
                        proxy.scrollTo("ScrollBottomPadding", anchor: .bottom)
                    }
                    .overlay(alignment: .bottom) {
                        if showNewMessageToast {
                            Text("새 메시지가 도착했어요")
                                .appFont(PretendardFontStyle.body2, textColor: .grayScale0)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.grayScale100.opacity(0.8))
                                .cornerRadius(12)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showNewMessageToast = false
                                    }
                                    viewModel.output.newMessage = false
                                    scrollToBottom(proxy: proxy)
                                }
                                .padding()
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut, value: showNewMessageToast)
                        }
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                            SelectedImageView(image: image) {
                                viewModel.selectedImages.remove(at: index)
                            }
                        }
                    }
                }.disabled(viewModel.selectedImages.isEmpty)
                
                // 메시지 입력 바
                MessageInputView(content: $viewModel.content, actions:
                                    MessageInputAction(
                                        onSendTapped: {
                                            viewModel.action(.sendButtonTapped)
                                        },
                                        onPhotoPicked: {
                                            isImagePickerTapped = true
                                        },
                                        onFilePicked: {
                                            isFilePickerTapped = true
                                        }
                                    )
                )
            }
            .disabled(viewModel.output.isLoading)
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
            
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView {
                    onBack()
                }
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.opponentNick)
                    .appFont(PaperlogyFontStyle.caption)
            }
        }
        .sheet(isPresented: $isImagePickerTapped) {
            ImagePickerSheetView(selectedImages: $viewModel.selectedImages)
        }
        .fullScreenCover(item: $imageTapped) { info in
            imageFullScreenCover(info: info)
        }
        .fullScreenCover(item: $fileTapped) { info in
            fileFullScreenCover(info: info)
        }
        .filePicker(isPresented: $isFilePickerTapped, selectedURL: $viewModel.selectedFileURL) {
            viewModel.action(.sendFile)
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .onAppear {
            /// 채팅방 진입시 푸시 알림 안오도록
            NotificationCenter.default.post(name: .didEnterChatRoom, object: viewModel.roomID)
        }
        .onDisappear {
            
            NotificationCenter.default.post(name: .didLeaveChatRoom, object: viewModel.roomID)
        }
        
        
    }
    
    // MARK: - 하단으로 스크롤
    
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo("ScrollBottomPadding", anchor: .bottom)
            }
        }
        
        
    }
    
    
    private func dateDivider(for date: Date) -> some View {
        Text(date.toDisplayString())
            .appFont(PretendardFontStyle.caption1, textColor: .grayScale60)
            .padding(.vertical, 8)
    }
    
    private func handleImageTap(path: String) {
        imageTapped = PreviewItem(path: path)
    }
    
    private func handleFileTap(path: String) {
        fileTapped = PreviewItem(path: path)
    }
    
    
    
    
    func imageFullScreenCover(info: PreviewItem) -> some View {
        
        ZoomableImageFullScreenView(
            viewModel: container.mediaFactory.makeZoomableImageFullScreenViewModel(),
            path: info.path
        )
    }
    
    func fileFullScreenCover(info: PreviewItem) -> some View {
        return PDFFullScreenView(path: info.path)
    }
    
}

struct MessageView: View {
    let message: ChatMessageEntity
    let onImageTap: (String) -> Void
    let onFileTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: message.isMine != true ? .leading : .trailing) {
            
            if let firstFile = message.files.first, firstFile.hasSuffix(".pdf") {
                PdfView(file: firstFile, onFileTapped: onFileTap)
            } else {
                PhotoGridView(paths: message.files, onImageTappped: onImageTap)
            }
            
            if !message.content.isEmpty {
                HStack(alignment: .bottom, spacing: 4) {
                    if message.isMine {
                        Spacer()
                        messageTimeView()
                        MessageBubleView(message: message)
                        
                    } else {
                        ProfileImageView(path: message.opponentInfo.profileImageURL, size: 36)
                        MessageBubleView(message: message)
                        messageTimeView()
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        
    }
    
    
    func messageTimeView() -> some View {
        Text(message.formatTime)
            .appFont(PretendardFontStyle.caption2, textColor: .grayScale60)
        
    }
}

struct MessageBubleView: View {
    
    let message: ChatMessageEntity
    
    var body: some View {
        
        Text(message.content)
            .appFont(PretendardFontStyle.body2, textColor: .grayScale90)
            .padding(10)
            .background(message.isMine != true ? .grayScale45 : .deepSeafoam)
            .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
        
    }
}



struct PdfView: View {
    
    let file: String
    let onFileTapped: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 24))
                .foregroundColor(.deepSeafoam)
            
            Text(URL(fileURLWithPath: file).lastPathComponent)
                .lineLimit(2)
                .appFont(PretendardFontStyle.body2, textColor: .grayScale90)
                .frame(width: 150)
            
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(.grayScale30)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            onFileTapped(file)
        }
        
        
    }
    
    
}

// MARK: 이미지 표시
struct PhotoGridView: View {
    let paths: [String]
    let onImageTappped: (String) -> (Void)
    var body: some View {
        VStack(spacing: 4) {
            switch paths.count {
            case 1:
                imageView(paths[0], size: 180, onImageTappped)
                
            case 2:
                HStack(spacing: 4) {
                    ForEach(paths.prefix(2), id: \.self) { image in
                        imageView(image, size: 90, onImageTappped)
                    }
                }
                
            case 3:
                HStack(spacing: 4) {
                    ForEach(paths.prefix(3), id: \.self) { image in
                        imageView(image, size: 6, onImageTappped)
                    }
                }
                
            case 4:
                VStack(spacing: 4) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                imageView(paths[index], size: 90, onImageTappped)
                            }
                        }
                    }
                }
                
            case 5:
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            imageView(paths[index], size: 60, onImageTappped)
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(3..<5, id: \.self) { index in
                            imageView(paths[index], size: 90, onImageTappped)
                        }
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
    
    func imageView(_ path: String, size: CGFloat, _ onTap: @escaping (String) -> Void ) -> some View {
        RemoteImageView(path: path)
            .frame(width: size, height: size)
            .clipped()
            .cornerRadius(8)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap(path)
            }
    }
}


// MARK: - 메시지 입력 바
private extension ChatRoomView {
    
    struct MessageInputView: View {
        @Binding var content: String
        let actions: MessageInputAction
        
        
        @State private var showPickerAlert: Bool = false
        
        var body: some View {
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(UIColor.separator))
                
                HStack(spacing: 12) {
                    Button(action: {
                        showPickerAlert = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.grayScale60)
                    }
                    .confirmationDialog("파일 선택", isPresented: $showPickerAlert) {
                        Button("사진 선택") {
                            actions.onPhotoPicked()
                        }
                        Button("파일 선택") {
                            actions.onFilePicked()
                        }
                        Button("닫기", role: .cancel) { }
                    }
                    
                    HStack(spacing: 8) {
                        CustomTextEditor(text: $content)
                    }

                    
                    Button {
                        actions.onSendTapped()
                        hideKeyboard()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .foregroundColor(content.isEmpty ? .grayScale60 : .deepSeafoam)
                    }
                    .disabled(content.isEmpty)
                    
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
        }
    }
    
    
}


struct SelectedImageView: View {
    
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(10)
            
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
            onDelete()
        }
    }
    
    
    
}
