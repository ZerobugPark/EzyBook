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
    
    @StateObject var viewModel: ChatRoomViewModel
    
    @State private var height: CGFloat = 40
    @State private var selectedImage: [UIImage] = []
    @EnvironmentObject var appState: AppState
    
    /// 화면전환 트리거
    @State var isPickerTapped: Bool = false
    
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // 채팅 메시지 리스트
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.output.chatList, id: \.chatID) { message in
                                
                                MessageView(message: message)
                                  
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.output.chatList.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
                
                // 메시지 입력 바
                MessageInputView(content: $viewModel.content, actions:
                                    MessageInputAction(
                                        onSendTapped: {
                                            viewModel.action(.sendButtonTapped)
                                        },
                                        onPhotoPicked: {
                                            isPickerTapped = true
                                        },
                                        onFilePicked: {
                                            
                                        }
                                    )
                )
            }
            .background(Color(UIColor.systemBackground))
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
        .sheet(isPresented: $isPickerTapped) {
            ImagePickerSheetView(selectedImages: $selectedImage) {
                print(selectedImage.count)
            }
        }
    }
    
    // MARK: - 하단으로 스크롤
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.output.chatList.last {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.chatID, anchor: UnitPoint.bottom)
            }
        }
    }
    
}

struct MessageView: View {
    let message: ChatMessageEntity

    var body: some View {
        VStack(alignment: message.isMine != true ? .leading : .trailing) {
            PhotoGridView(paths: message.files)
            HStack(alignment: .bottom, spacing: 4) {
                if message.isMine {
                    Spacer()
                    messageTimeView()
                    MessageBubleView(message: message)
                    
                } else {
                    MessageBubleView(message: message)
                    messageTimeView()
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 12)
  
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
            .overlay(alignment: message.isMine != true ? .bottomLeading : .bottomTrailing) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.title3)
                    .rotationEffect(.degrees(message.isMine != true ? 45: -45))
                    .offset(x: message.isMine != true ? -8 : 8, y: 8)
                    .foregroundStyle(message.isMine != true ? .grayScale45 : .deepSeafoam)
            }
            
        
    }
}

struct PhotoGridView: View {
    let paths: [String]
    
    var body: some View {
        VStack(spacing: 4) {
            switch paths.count {
            case 1:
                imageView(paths[0], size: 180)
                
            case 2:
                HStack(spacing: 4) {
                    ForEach(paths.prefix(2), id: \.self) { image in
                        imageView(image, size: 90)
                    }
                }
                
            case 3:
                HStack(spacing: 4) {
                    ForEach(paths.prefix(3), id: \.self) { image in
                        imageView(image, size: 60)
                    }
                }
                
            case 4:
                VStack(spacing: 4) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                imageView(paths[index], size: 90)
                            }
                        }
                    }
                }
                
            case 5:
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            imageView(paths[index], size: 60)
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(3..<5, id: \.self) { index in
                            imageView(paths[index], size: 90)
                        }
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
    
    func imageView(_ path: String, size: CGFloat) -> some View {
        RemoteImageView(path: path)
            .frame(width: size, height: size)
            .clipped()
            .cornerRadius(8)
            .contentShape(Rectangle())
            .onTapGesture {
                print("Tapped")
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
                        TextField("메시지를 입력하세요", text: $content, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    
                    Button {
                        actions.onSendTapped()
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





//struct ImprovedMessageRow: View {
//    let message: ChatMessageEntity
//
//    var body: some View {
//        GeometryReader { geometry in
//            HStack(alignment: .bottom, spacing: 0) {
//                if message.isMine {
//                    Spacer()
//                    HStack(alignment: .bottom, spacing: 6) {
//                        messageTimeView()
//                        myMessageBubble(maxWidth: geometry.size.width * 0.6)
//                    }
//                } else {
//                    VStack(alignment: .leading, spacing: 4) {
//                        // 이미지 영역
//                        if !message.files.isEmpty {
//                            HStack(spacing: 4) {
//                                Spacer().frame(width: 40)
//                                ForEach(message.files, id: \.self) { path in
//                                    RemoteImageView(path: path)
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                                }
//                                Spacer()
//                            }
//                        }
//
//                        // 메시지 영역
//                        HStack(alignment: .bottom, spacing: 6) {
//                            ProfileImageView(path: message.opponentInfo.profileImageURL, size: 32)
//                            otherMessageBubble(maxWidth: geometry.size.width * 0.55)
//                            messageTimeView()
//                            Spacer()
//                        }
//                    }
//                }
//            }
//        }
//        .frame(height: calculateRowHeight())
//        .padding(.horizontal, 30)
//    }
//
//    @ViewBuilder
//    func myMessageBubble(maxWidth: CGFloat) -> some View {
//        HStack {
//            Text(message.content)
//                .multilineTextAlignment(.trailing)
//                .lineLimit(nil)
//        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 8)
//        .background(Color.yellow.opacity(0.8))
//        .clipShape(MessageBubbleShape(isFromMe: true))
//        .frame(minWidth: 44)
//        .frame(maxWidth: maxWidth, alignment: .trailing)
//    }
//
//    @ViewBuilder
//    func otherMessageBubble(maxWidth: CGFloat) -> some View {
//        HStack {
//            Text(message.content)
//                .multilineTextAlignment(.leading)
//                .lineLimit(nil)
//        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 8)
//        .background(Color(UIColor.secondarySystemBackground))
//        .clipShape(MessageBubbleShape(isFromMe: false))
//        .frame(minWidth: 44)
//        .frame(maxWidth: maxWidth, alignment: .leading)
//    }
//
//    @ViewBuilder
//    func messageTimeView() -> some View {
//        Text(message.formatTime)
//            .font(.caption2)
//            .foregroundColor(.secondary)
//            .frame(minWidth: 30, alignment: message.isMine ? .trailing : .leading)
//    }
//
//    private func calculateRowHeight() -> CGFloat {
//        // 이미지가 있는 경우의 높이 계산
//        let imageHeight: CGFloat = message.files.isEmpty ? 0 : 104
//
//        // 텍스트 높이 계산 (대략적)
//        let textHeight: CGFloat = max(40, estimateTextHeight())
//
//        return max(textHeight, imageHeight) + 8 // 여백 추가
//    }
//
//
//    func estimateTextHeight() -> CGFloat {
//        let font = UIFont.systemFont(ofSize: 16)
//        let maxWidth = UIScreen.main.bounds.width * 0.6 - 24 // 패딩 제외
//
//        let boundingRect = message.content.boundingRect(
//            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
//            options: [.usesLineFragmentOrigin, .usesFontLeading],
//            attributes: [.font: font],
//            context: nil
//        )
//
//        return boundingRect.height + 16 // 상하 패딩
//    }
//
//    // MARK: - 더 자연스러운 버블 크기를 위한 최적화 버전
//    struct NaturalSizedMessageRow: View {
//        let message: ChatMessageEntity
//
//        var body: some View {
//            HStack(alignment: .bottom, spacing: 8) {
//                if message.isMine {
//                    Spacer()
//                    HStack(alignment: .bottom, spacing: 4) {
//                        messageInfo()
//                        myMessageBubble()
//                    }
//                } else {
//                    VStack(alignment: .leading, spacing: 4) {
//                        // 이미지 영역
//                        if !message.files.isEmpty {
//                            HStack(spacing: 4) {
//                                Spacer().frame(width: 40)
//                                ForEach(message.files, id: \.self) { path in
//                                    RemoteImageView(path: path)
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                                }
//                                Spacer()
//                            }
//                        }
//                        // 메시지 영역
//                        HStack(alignment: .bottom, spacing: 4) {
//                            ProfileImageView(path: message.opponentInfo.profileImageURL, size: 32)
//                            otherMessageBubble()
//                            messageInfo()
//                            Spacer()
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal, 30)
//        }
//
//        @ViewBuilder
//        func myMessageBubble() -> some View {
//            Text(message.content)
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(
//                    Color.yellow.opacity(0.8)
//                        .clipShape(MessageBubbleShape(isFromMe: true))
//                )
//                .layoutPriority(1) // 텍스트 크기를 우선시
//        }
//
//        @ViewBuilder
//        func otherMessageBubble() -> some View {
//            Text(message.content)
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(
//                    Color(UIColor.secondarySystemBackground)
//                        .clipShape(MessageBubbleShape(isFromMe: false))
//                )
//                .layoutPriority(1) // 텍스트 크기를 우선시
//        }
//
//        @ViewBuilder
//        func messageInfo() -> some View {
//            Text(message.formatTime)
//                .font(.caption2)
//                .foregroundColor(.secondary)
//                .fixedSize() // 시간 텍스트는 고정 크기
//        }
//
//    }
//}
