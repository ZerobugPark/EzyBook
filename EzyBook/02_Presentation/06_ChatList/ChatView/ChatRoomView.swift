//
//  ChatRoomView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//
import SwiftUI


// MARK: - 메인 채팅 뷰
//struct ChatRoomView: View {
//    
//    @StateObject var viewModel: ChatRoomViewModel
//    @EnvironmentObject var appState: AppState
//    let onBack: () -> Void
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//            
//                // 채팅 메시지 리스트
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        test()
//                    }
//                    .onChange(of: viewModel.output.chatList.count) { _ in
//                        scrollToBottom(proxy: proxy)
//                    }
//                }
//                
//                // 메시지 입력 바
//                messageInputBar()
//            }
//            .background(Color(UIColor.systemBackground))
//        }
//        .onAppear {
//            viewModel.action(.startChat)
//            
//        }
//        .navigationBarBackButtonHidden(true)
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                BackButtonView {
//                    onBack()
//                }
//            }
//            ToolbarItem(placement: .principal) {
//                Text(viewModel.output.opponentProfile.nick)
//                    .appFont(PaperlogyFontStyle.caption)
//            }
//        }
//        .commonAlert(
//            isPresented: Binding(
//                get: { viewModel.output.unknownedUser },
//                set: { isPresented in
//                    onBack()
//                }
//            ),
//            title: "안내",
//            message: "알 수 없는 유저입니다"
//        )
//    }
//    
//    private func test() -> some View {
//        LazyVStack(spacing: 8) {
//            ForEach(viewModel.output.chatList, id: \.chatID) { message in
//                MessageRow(message: message)
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//    }
//    
//    // MARK: - 하단으로 스크롤
//    private func scrollToBottom(proxy: ScrollViewProxy) {
//        if let lastMessage = viewModel.output.chatList.last {
//            withAnimation(.easeInOut(duration: 0.3)) {
//                proxy.scrollTo(lastMessage.chatID, anchor: UnitPoint.bottom)
//            }
//        }
//    }
//    
//    // MARK: - 메시지 전송
//    private func sendMessage() {
//        viewModel.action(.sendButtonTapped)
//    }
//}
//
//// MARK: - 상단 네비게이션 바
//extension ChatRoomView {
//    @ViewBuilder
//    func chatNavigationBar() -> some View {
//        HStack {
//            Button(action: {}) {
//                Image(systemName: "chevron.left")
//                    .font(.title2)
//                    .foregroundColor(.primary)
//            }
//            
//            VStack(alignment: .center) {
//                HStack(spacing: 12) {
//      
//                    Text("친구 이름")
//                        .font(.headline)
//                        .fontWeight(.medium)
//
//                }
//            }
//            
//            Spacer()
//        
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(Color(UIColor.systemBackground))
//        .overlay(
//            Rectangle()
//                .frame(height: 0.5)
//                .foregroundColor(Color(UIColor.separator)),
//            alignment: .bottom
//        )
//    }
//}
//
//// MARK: - 메시지 입력 바
//extension ChatRoomView {
//    @ViewBuilder
//    func messageInputBar() -> some View {
//        VStack(spacing: 0) {
//            Rectangle()
//                .frame(height: 0.5)
//                .foregroundColor(Color(UIColor.separator))
//            
//            HStack(spacing: 12) {
//                Button(action: {}) {
//                    Image(systemName: "plus")
//                        .font(.title2)
//                        .foregroundColor(.secondary)
//                }
//                
//                HStack(spacing: 8) {
//                    TextField("메시지를 입력하세요", text: $viewModel.content)
//                        .textFieldStyle(PlainTextFieldStyle())
//                    
//                    if !viewModel.content.isEmpty {
//                        Button(action: {}) {
//                            Image(systemName: "face.smiling")
//                                .font(.title2)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(Color(UIColor.secondarySystemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                
//                Button(action: sendMessage) {
//                    Image(systemName: "paperplane.fill")
//                        .font(.title2)
//                        .foregroundColor(viewModel.content.isEmpty ? .secondary : .blue)
//                }
//                .disabled(viewModel.content.isEmpty)
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//        }
//        .background(Color(UIColor.systemBackground))
//    }
//}
//
//// MARK: - 메시지 행
//struct MessageRow: View {
//    let message: ChatMessageEntity
//    
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if message.isMine {
//                Spacer()
//                messageInfo()
//                myMessageBubble()
//            } else {
//               // ProfileImageView(image: nil, size: 32)
//                otherMessageBubble()
//                Spacer()
//            }
//        }
//    }
//    
//    // MARK: - 내 메시지 버블
//    @ViewBuilder
//    func myMessageBubble() -> some View {
//        Text(message.content)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(Color.yellow.opacity(0.8))
//            .clipShape(MessageBubbleShape(isFromMe: true))
//            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
//    }
//    
//    // MARK: - 상대방 메시지 버블
//    @ViewBuilder
//    func otherMessageBubble() -> some View {
//        Text(message.content)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(Color(UIColor.secondarySystemBackground))
//            .clipShape(MessageBubbleShape(isFromMe: false))
//            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
//    }
//    
//    // MARK: - 메시지 정보 (시간, 읽음 표시)
//    @ViewBuilder
//    func messageInfo() -> some View {
//        VStack(alignment: .trailing, spacing: 2) {
////            if !message.isRead {
////                Circle()
////                    .fill(Color.red)
////                    .frame(width: 6, height: 6)
////            }
//            
////            Text(formatTime(message.createdAt))
////                .font(.caption2)
////                .foregroundColor(.secondary)
//        }
//    }
//    
//    // MARK: - 시간 포맷팅
//    private func formatTime(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter.string(from: date)
//    }
//}
//
//
//
//// MARK: - 메시지 버블 모양
//struct MessageBubbleShape: Shape {
//    let isFromMe: Bool
//    
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: isFromMe ?
//                [.topLeft, .topRight, .bottomLeft] :
//                [.topLeft, .topRight, .bottomRight],
//            cornerRadii: CGSize(width: 16, height: 16)
//        )
//        return Path(path.cgPath)
//    }
//}
//
//
