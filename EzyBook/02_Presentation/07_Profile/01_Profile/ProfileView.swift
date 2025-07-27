//
//  ProfileView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject var viewModel: ProfileViewModel
    @StateObject var supplementviewModel: ProfileSupplementaryViewModel
    @ObservedObject var coordinator: ProfileCoordinator
    @EnvironmentObject var appState: AppState
    @Environment(\.displayScale) var scale
    
    
    /// 이미지 피커
    @State private var isImagePickerPresented = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var selectedImage: IdentifiableImage?
    
    var data: ProfileLookUpModel {
        viewModel.output.profile
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    makeProfileSection()
                    makeMenuView()
                }
                .scrollIndicators(.hidden)
                .disabled(viewModel.output.isLoading)
                
                LoadingOverlayView(isLoading: viewModel.output.isLoading)
            }
            .background(.grayScale15)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    TitleTextView(title: "PROFILE")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(.iconSetting)
                            .renderingMode(.template)
                            .foregroundColor(.grayScale60)
                    }
                }
            }
        }
        .photosPicker(
            isPresented: $isImagePickerPresented,
            selection: $photoItems,
            maxSelectionCount: 1,
            matching: .images,
            photoLibrary: .shared()
        )
        .onAppear {
            viewModel.action(.onAppearRequested)
            supplementviewModel.action(.onAppearRequested)
        }
        .onChange(of: photoItems) { newItems in
            guard let firstItem = newItems.first else {
                selectedImage = nil
                return
            }
            
            Task {
                if let data = try? await firstItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = IdentifiableImage(image: image)
                    
                }
            }
        }
        .fullScreenCover(item: $selectedImage) { identifiable in
            coordinator.makeConfirmImageView(
                image: identifiable.image,
                onConfirm: { image in
                    viewModel.action(.didSelectedImageData(image: image))
                    selectedImage = nil
                    photoItems = []
                },
                onCancel: {
                    selectedImage = nil
                    photoItems = []
                }
            )
        }
        .withCommonUIHandling(viewModel) { code in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .withCommonUIHandling(supplementviewModel) { code in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .loadingOverlayModify(viewModel.output.isLoading)
    }
    
    
}

// MARK: 프로필 설정 뷰

extension ProfileView {
    private func makeProfileSection() -> some View {
        // MARK: - 프로필 이미지
        VStack(spacing: 40) {
            makeProfileImageView()
            makeprofileCardView()
        }
        .padding(.vertical, 20)
    }
    
    private func makeProfileImageView() -> some View {
        ZStack {
            Circle()
                .fill(.grayScale0)
                .frame(width: 140, height: 140)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.deepSeafoam.opacity(0.6), Color.blackSeafoam.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay {
                    /// 업로드했는데, 서버에서 다시 받아오면 왜 URL이 없을까?.
                    if let image = viewModel.output.profile.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 120, height: 120)
                    } else {
                        Image(.tabBarProfileFill)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.grayScale0)
                    }
                    
                    
                    
                }
                .onTapGesture {
                    //TODO: 미리보기
                }
            
            
            makeModifyProfileImage()
        }
    }
    
    
    private func makeModifyProfileImage() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    //TODO: 이미지 수정으로 이동
                    isImagePickerPresented = true
                } label: {
                    Circle()
                        .fill(Color.blackSeafoam.opacity(1.0))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.grayScale0)
                        )
                }
                .contentShape(Circle())
                .offset(x: -10, y: -10)
            }
        }
        .frame(width: 140, height: 140)
    }
    
    
    // MARK: - Profile Card View
    private func makeprofileCardView() -> some View {
        VStack(spacing: 20) {
            // 이름과 편집 버튼
            ZStack {
                Text(data.nick)
                    .appFont(PaperlogyFontStyle.body, textColor: .grayScale100)
                
                HStack {
                    Spacer()
                    Button(action: {
                        print("edit profile")
                    }) {
                        Text("수정")
                            .appFont(PretendardFontStyle.body1, textColor: .grayScale75)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.grayScale60.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            // 한줄 소개
            Text(data.introduction)
                .appFont(PretendardFontStyle.body2, textColor: .grayScale100)
                .multilineTextAlignment(.center)
            
            Spacer(minLength: 20)
            
            // 통계
            HStack(spacing: 40) {
                statView(
                    icon: "star.fill",
                    value: "1,342,545원",
                    label: "총 사용 금액",
                    iconColor: .blue
                )
                
                statView(
                    icon: "diamond.fill",
                    value: "148,400P",
                    label: "누적 적립 포인트",
                    iconColor: .blue
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(.grayScale0)
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.1), radius: 10, x: 0, y: -5)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Functions
    private func tagView(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(.grayScale0)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(0.7))
            )
    }
    
    private func statView(icon: String, value: String, label: String, iconColor: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
}

// MARK: 활동 관련 테이블 뷰

extension ProfileView {
    
    private func makeMenuView() -> some View {
        VStack(spacing: 16) {
            ForEach(menuSections) { section in
                makeMenuSection(section: section)
            }
        }
    }
    
    private func makeMenuSection(section: MenuSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 섹션 타이틀
            HStack {
                Text(section.title)
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                    .padding(.leading, 25)
                    .padding(.bottom, 8)
                Spacer()
            }
            
            /// 메뉴 아이템들
            VStack(spacing: 1) {
                ForEach(Array(section.items.enumerated()), id: \.offset) { index, item in
                    menuRow(icon: item.icon, title: item.title, action: item.action)
                    
                    /// 마지막 아이템이 아닐 때만 Divider 표시
                    if index < section.items.count - 1 {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal, 20)
                    }
                }
            }
            .background(.grayScale0)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    private func menuRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
            
            Text(title)
                .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
            
            Spacer()
            
            Image(.iconChevron)
                .renderingMode(.template)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.grayScale60)
                .rotationEffect(.degrees(180))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.grayScale0)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

// MARK: Models

extension ProfileView {
    
    // MARK: - 메뉴 섹션 데이터
    private var menuSections: [MenuSection] {
        [
            MenuSection(
                title: "나의 활동",
                items: [
                    MenuItem(icon: "doc.text", title: "내 포스팅") {
                        print("내 포스팅")
                    },
                    MenuItem(icon: "heart.text.clipboard", title: "내가 좋아요한 게시글") {
                        print("내가 좋아요한 게시글")
                    },
                    MenuItem(icon: "heart", title: "내가 좋아요한 액티비티") {
                        print("내가 좋아요한 액티비티")
                    },
                    MenuItem(icon: "pencil", title: "리뷰 조회") {
                        print("리뷰 조회")
                    }
                ]
            ),
            MenuSection(
                title: "나의 결제",
                items: [
                    MenuItem(icon: "square.3.layers.3d", title: "주문 내역 조회") {
                        coordinator.push(.orderListView(list: supplementviewModel.output.orderList))
                    },
                    MenuItem(icon: "creditcard", title: "결제 영수증 조회") {
                        print("결제 영수증 조회")
                    }
                ]
            )
        ]
    }
    
    struct IdentifiableImage: Identifiable {
        let id = UUID()
        let image: UIImage
    }
    
    struct MenuItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let action: () -> Void
    }
    
    struct MenuSection: Identifiable {
        let id = UUID()
        let title: String
        let items: [MenuItem]
    }
    
}

