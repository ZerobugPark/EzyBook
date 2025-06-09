//
//  ProfileView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI


struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

struct ProfileView: View {
    
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    // MARK: - 프로필 이미지
                    Section {
                        VStack(spacing: 40) {
                            profileImageView()
                            profileCardView()
                        }
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets()) // 전체 너비로 확장
                        .background(Color.clear)
                    }
                    .listRowBackground(Color.clear)
                    .allowsHitTesting(false)
                    
                    // MARK: - 나의 거래
                    Section(header:
                                Text("나의 활동")
                        .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                        .padding(.leading, -12) // ✅ 위치 조정
                            
                    ) {
                        menuRow(icon: "doc.text", title: "판매내역")
                        menuRow(icon: "bag", title: "구매내역")
                        menuRow(icon: "laptopcomputer", title: "관심내역")
                    }
                    
                    
                }
                .scrollContentBackground(.hidden)
                .background(.grayScale15)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("PROFILE")
                            .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
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
        }
 
    }

    // MARK: - Section Header Helper
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.black)
            .textCase(nil)
    }
    
    private func profileImageView() -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 140, height: 140)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // 스키 이미지 placeholder
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "figure.skiing.downhill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )
            
            // 카메라 아이콘
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Circle()
                            .fill(Color.blue.opacity(0.8))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            )
                    }
                    .offset(x: -10, y: -10)
                }
            }
            .frame(width: 140, height: 140)
        }
    }
    
    // MARK: - Profile Card View
    private func profileCardView() -> some View {
        VStack(spacing: 20) {
            // 이름과 편집 버튼
            HStack {
                Text("썩썩한 새싹이")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {}) {
                    Text("수정")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            
            // 한줄 소개
            Text("액티비티를 즐기고 기록하는 것을 좋아하는 새싹이에요!")
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .underline()
            
            // 태그들
            HStack(spacing: 8) {
                tagView(text: "1위 튜어", color: .blue)
                tagView(text: "2위 액티비티", color: .blue)
                tagView(text: "3위 체험", color: .blue)
                Spacer()
            }
            
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
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.1), radius: 10, x: 0, y: -5)
        .padding(.horizontal, 20)
    }
    

    
    // MARK: - Helper Functions
    private func tagView(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(.white)
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
    
    private func menuRow(icon: String, title: String) -> some View {
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
        .contentShape(Rectangle()) // ✅ 터치 영역 확장
        .onTapGesture {
            print("hgere")
        }
    }
}


