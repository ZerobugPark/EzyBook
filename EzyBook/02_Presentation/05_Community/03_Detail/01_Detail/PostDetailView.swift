//
//  PostDetailView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import SwiftUI

struct CommentActions {
    let onDelete: (String) -> Void
    let onReply: ((CommentEntity) -> Void)?
    let onEdit: (String, String) -> Void
}

struct ModifyComment: Identifiable {
    let id: String
    let text: String
}


struct PostDetailView: View {
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: PostDetailViewModel
    @ObservedObject  var coordinator: CommunityCoordinator
    
    @State private var selectedIndex = 0
    /// 화면전환 트리거
    @State private var selectedMedia: SelectedMedia?
    @State private var replyingComment: CommentEntity? = nil
    @State private var modifyComment: ModifyComment? = nil
    
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
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
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        if !viewModel.output.postDetailInfo.files.isEmpty {
                            PostTopMediaSection(
                                data: viewModel.output.postDetailInfo,
                                thumbnails: viewModel.output.postDetailInfo.files,
                                selectedIndex: $selectedIndex,
                                selectedMedia: $selectedMedia
                            )
                        } else {
                            Spacer().frame(height: 80) // Ensure space below toolbar when no media exists
                        }
                        
                        PostMainContentView(data: viewModel.output.postDetailInfo)
                        
                        
                        CommentListView(
                            data: viewModel.output.postDetailInfo.comments,
                            actions: CommentActions(
                                onDelete: { commentID in
                                    viewModel.action(.deleteComment(commentID: commentID))
                                },
                                onReply: { data in
                                    replyingComment = data
                                },
                                onEdit: { id, content in
                                    modifyComment = ModifyComment(id: id, text: content)
                                }
                            )
                        )
                    }
                }
                .disabled(viewModel.output.isLoading)
                
                LoadingOverlayView(isLoading: viewModel.output.isLoading)
            }
            
            Divider()
            
            HStack {
                TextField("댓글을 입력해주세요", text: $viewModel.comment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .focused($isTextEditorFocused)
                
                Button(action: {
                    viewModel.action(.writeComment(parentID: nil))
                    isTextEditorFocused = false
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.comment.isEmpty ? .grayScale45 : .deepSeafoam)
                    
                }
                .disabled(viewModel.comment.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .background(Color.white)
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(.grayScale15)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ActivityKeepButtonView(isKeep: viewModel.output.postDetailInfo.isLike) {
                    viewModel.action(.keepButtonTapped)
                }
            }
        }
        .fullScreenCover(item: $selectedMedia) { media in
            if media.isVideo {
                coordinator.makeVideoPlayerView(path: viewModel.output.postDetailInfo.files[media.id])
            } else {
                coordinator.makeImageViewer(path: viewModel.output.postDetailInfo.files[media.id])
            }
        }
        .fullScreenCover(item: $replyingComment) { data in
            coordinator.makeReplyView(data: data, postID: viewModel.postID) {
                
                viewModel.action(.reloadData)
            }
        }
        .fullScreenCover(item: $modifyComment) { data in
            coordinator.makeModifyView(data: data)  { text in
                viewModel.action(.modifyContent(commentID: data.id, text: text))
            }
        }
        
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .loadingOverlayModify(viewModel.output.isLoading)
        
    }
}


// MARK: 이미지 섹션
private extension PostDetailView {
    struct PostTopMediaSection: View {
        let data: PostEntity
        let thumbnails: [String]
        
        @Binding var selectedIndex: Int
        @Binding var selectedMedia: SelectedMedia?
        
        
        
        var body: some View {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(thumbnails.enumerated()), id: \.0) { index, path in
                        ZStack {
                            RemoteImageView(path: path)
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                            
                            if thumbnails[index].hasSuffix(".mp4") {
                                Image(.playButton)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .shadow(radius: 10)
                            }
                        }
                        .onTapGesture {
                            let isVideo = thumbnails[index].hasSuffix(".mp4")
                            selectedMedia = SelectedMedia(id: index, isVideo: isVideo)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)
                
                VStack(spacing: 8) {
                    indicatorView
                }
                .padding(.bottom, 40)
            }
            
        }
        
        private var indicatorView: some View {
            HStack(spacing: 6) {
                ForEach(0..<thumbnails.count, id: \.self) { index in
                    if index == selectedIndex {
                        Capsule()
                            .fill(.grayScale45)
                            .frame(width: 30, height: 8)
                            .transition(.scale)
                    } else {
                        Circle()
                            .fill(.grayScale60)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        }
    }
}




// MARK: 타이틀 및 후기
private extension PostDetailView {
    
    struct PostMainContentView: View {
        
        let data: PostEntity
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    ProfileImageView(path: data.creator.profileImage, size: 32)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(data.creator.nick)
                            .appFont(PretendardFontStyle.body2, textColor: .grayScale90)
                        Text(data.relativeTimeDescription)
                            .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
                        
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                
                Text(data.title)
                    .appFont(PaperlogyFontStyle.body, textColor: .grayScale90)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(data.content)
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            
        }
        
    }
}

// MARK: 댓글영역

struct CommentListView: View {
    
    // MARK: - 댓글 및 대댓글
    let data: [CommentEntity]
    let actions: CommentActions
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("댓글")
                .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
            
            if data.isEmpty {
                
                Text("아직 댓글이 없어요. \n 가장 먼저 댓글을 남겨보세요.")
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale60)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 30)
                
            } else {
                ForEach(data, id: \.commentID) { data in
                    CommentItemView(data: data, actions: actions)
                }
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
    
    
    
}

struct CommentItemView: View {
    
    let data: CommentEntity
    let isOwner: Bool
    let actions: CommentActions
    //    let onDeleteTapped: (String) -> Void
    //    /// 옵셔널 클로저는 자동으로 escaping
    //    let onEditTapped: (String) -> Void
    //    let onReplyTapped: ((CommentEntity) -> Void)?
    
    init(
        data: CommentEntity,
        actions: CommentActions
    ) {
        self.data = data
        self.isOwner = data.creator.userID == UserSession.shared.currentUser?.userID
        self.actions = actions
    }
    
    
    var body: some View {
        CommentContentView(
            data: data,
            isOwner: isOwner,
            onEdit: { data in
                actions.onEdit(data.commentID, data.content)
            },
            onDelete: { data in
                actions.onDelete(data.commentID)
            },
            onReply: actions.onReply == nil ? nil : { data in actions.onReply?(data) }
        )
        
        if !data.replies.isEmpty {
            ForEach(data.replies, id: \.commentID) { data in
                ReplyContentView(
                    data: data,
                    isOwner: isOwner
                ) {
                    actions.onEdit(data.commentID, data.content)
                } onDelete: {
                    actions.onDelete(data.commentID)
                }
                
            }
            
        }
    }
    
}

struct CommentContentView: View {
    
    let data: CommentEntity
    let isOwner: Bool
    let onEdit: (CommentEntity) -> Void
    let onDelete: (CommentEntity) -> Void
    let onReply: ((CommentEntity) -> Void)?
    @State private var isActionSheetPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                ProfileImageView(path: data.creator.profileImage, size: 28)
                VStack(alignment: .leading, spacing: 0) {
                    Text(data.creator.nick)
                        .appFont(PretendardFontStyle.body3, textColor: .grayScale90)
                    Text(data.createdAt.toRelativeTimeDescription())
                        .appFont(PretendardFontStyle.caption2, textColor: .grayScale75)
                    
                }
                Spacer()
                CommentActionButtonView(
                    isOwner: isOwner,
                    onEdit: {
                        onEdit(data)
                    },
                    onDelete: {
                        onDelete(data)
                    }
                )
            }
            
            Text(data.content)
                .appFont(PretendardFontStyle.body3, textColor: .grayScale90)
                .padding(.top, 5)
                .padding(.leading, 40)
            
            if let onReply {
                
                if data.replies.isEmpty {
                    Button(action: {
                        onReply(data)
                    }) {
                        Label("답글쓰기", systemImage: "bubble.left")
                            .appFont(PretendardFontStyle.caption1, textColor: .grayScale75)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading,  40)
                }
                
            }
            
            
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
        
    }
    
    
}


struct ReplyContentView: View {
    
    
    let data: ReplyEntity
    let isOwner: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var isActionSheetPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                ProfileImageView(path: data.creator.profileImage, size: 24)
                VStack(alignment: .leading, spacing: 0) {
                    Text(data.creator.nick)
                        .appFont(PretendardFontStyle.body3, textColor: .grayScale90)
                    Text(data.createdAt.toRelativeTimeDescription())
                        .appFont(PretendardFontStyle.caption2, textColor: .grayScale75)
                    
                }
                Spacer()
                
                CommentActionButtonView(
                    isOwner: isOwner,
                    onEdit: {
                        onEdit()
                    },
                    onDelete: {
                        onDelete()
                    }
                )
                
            }
            
            Text(data.content)
                .appFont(PretendardFontStyle.body3, textColor: .grayScale90)
                .padding(.top, 5)
                .padding(.leading, 40)
            
            
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 10)
        .padding(.leading, 40)
        
        
    }
    
}


struct CommentActionButtonView: View {
    let isOwner: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        Group {
            if isOwner {
                Button(action: {
                    isPresented = true
                }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.gray)
                }
                .confirmationDialog("댓글 관리", isPresented: $isPresented, titleVisibility: .visible) {
                    Button("수정하기", action: onEdit)
                    Button("삭제하기", role: .destructive, action: onDelete)
                    Button("닫기", role: .cancel) { }
                }
            }
        }
    }
}


