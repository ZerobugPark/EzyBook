//
//  ReplyView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import SwiftUI



struct ReplyView: View {
    
    @Environment(\.dismiss) private var dismiss
    private let coordinator: CommunityCoordinator
    @StateObject var viewModel: ReplyViewModel
    
    let onChagned: () -> Void
    
    @FocusState private var isTextEditorFocused: Bool
    @State private var modifyComment: ModifyComment? = nil
    
    @State private var isChanged: Bool = false
    
    init(coordinator: CommunityCoordinator, viewModel: ReplyViewModel, onChagned: @escaping () -> Void) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onChagned = onChagned
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CommonNavigationBar(
                title: "댓글 ", leadingAction: {
                    dismiss()
                })
            ZStack {
                
                if isTextEditorFocused {
                    Rectangle()
                        .foregroundColor(.clear) // 시각적으로는 보이지 않지만
                        .contentShape(Rectangle()) // 터치 이벤트 영역 지정
                        .onTapGesture {
                            isTextEditorFocused = false // 포커스 해제 → 키보드 내려감
                        }
                        .ignoresSafeArea() // 화면 전체 덮게
                        .zIndex(1) // ScrollView 위에 올라오도록 보장
                }
                
                ScrollView(.vertical, showsIndicators: false)  {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        if let comment = viewModel.output.commentInfo {
                            VStack(alignment: .leading, spacing: 12) {
                                CommentItemView(
                                    data: comment,
                                    actions: CommentActions(
                                        onDelete: { commentID in
                                            viewModel.action(.deleteComment(commentID: commentID))
                                        },
                                        onReply: nil,
                                        onEdit: { id, content in
                                            modifyComment = ModifyComment(id: id, text: content)
                                        }
                                    ))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
                
            }
            
            Divider()
            
            HStack {
                TextField("댓글을 입력해주세요", text: $viewModel.replyMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .focused($isTextEditorFocused)
                    .disabled(!(viewModel.output.commentInfo?.replies.isEmpty ?? true))
                
                Button(action: {
                    viewModel.action(.writeReply)
                    isChanged = true
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.replyMessage.isEmpty ? .grayScale45 : .deepSeafoam)
                    
                }
                .disabled(viewModel.replyMessage.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .background(Color.white)
        }
        .onChange(of: viewModel.output.onClosed) { _ in
            dismiss()
        }
        .fullScreenCover(item: $modifyComment) { data in
            coordinator.makeModifyView(data: data) { text in
                viewModel.action(.modifyContent(commentID: data.id, text: text))
                isChanged = true
            }
        }
        .onDisappear {
            if isChanged { onChagned() }
        }
        
    }
    
}

