//
//  MainTabView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI


enum Tab: String, CaseIterable {
    case home = "Home"
    case community = "Community"
    case chat = "Chat"
    case profile = "Profile"
    
    var tabImage: Image {
        switch self {
        case .home:
                .init(.tabBarHomeEmpty)
        case .community:
                .init(.tabBarFrameEmpty)
        case .chat:
                .init(.tabBarKeepEmpty)
        case .profile:
                .init(.tabBarProfileEmpty)
        }
    }
    
    /// 위치 계산, 순서 기반 동작으로 연산할 때 필요할 수도 있음
    var  index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}

struct MainTabView: View {
    
    @State private var activeTab: Tab = .home
    
    /// For Smooth Shape Sliding Effect, We're going to use Matched Geometry
    @Namespace private var animation
    @State private var tabShapePosition: CGPoint = .zero
    
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var homeCoordinator: HomeCoordinator
    @StateObject var communityCoordinator: CommunityCoordinator
    @StateObject var chatCoordinator: ChatCoordinator
    @StateObject var profileCoordinator: ProfileCoordinator
    
    
    init(container: DIContainer) {
        _homeCoordinator = StateObject(
            wrappedValue: HomeCoordinator(
                container: container
            )
        )
        _communityCoordinator = StateObject(
            wrappedValue: CommunityCoordinator(container: container)
        )
        _chatCoordinator = StateObject(
            wrappedValue: ChatCoordinator(container: container)
        )
        _profileCoordinator = StateObject(
            wrappedValue:  ProfileCoordinator(
                container: container
            )
        )
        
        /// TabBar Hidden이 안될 때,
        //UITabBar.appearance().isHidden = true
      }

    private var isCurrentTabbarHidden: Bool {
        switch activeTab {
        case .home:
            return homeCoordinator.isTabbarHidden
        case .community:
            return communityCoordinator.isTabbarHidden
        case .chat:
            return false // 예시: 탭바 숨김 안 함
        case .profile:
            return profileCoordinator.isTabbarHidden
        }
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                HomeCoordinatorView(coordinator: homeCoordinator)
                    .tag(Tab.home)
                    .toolbar(.hidden, for: .tabBar) ///Hiding Native Tab Bar
    
                CommunityCoordinatorView(coordinator: communityCoordinator)
                    .tag(Tab.community)
                    ///Hiding Native Tab Bar
                    .toolbar(.hidden, for: .tabBar)
                
                ChatCoordinatorView(coordinator: chatCoordinator)
                    .tag(Tab.chat)
                    ///Hiding Native Tab Bar
                    .toolbar(.hidden, for: .tabBar)
                
                ProfileViewCoordinatorView(coordinator: profileCoordinator)
                    .tag(Tab.profile)
                    ///Hiding Native Tab Bar
                    .toolbar(.hidden, for: .tabBar)
            }
            .background(.red)
        }
        
        if !isCurrentTabbarHidden {
            CustomTabbar()
                .allowsHitTesting(!appState.isLoding)
                .animation(.easeInOut(duration: 0.25), value: isCurrentTabbarHidden)
        }

    }
    
    
    /// Custome Tab Bar
    /// With More Easy Customization
    @ViewBuilder
    func CustomTabbar(_ tint: Color = Color(.deepSeafoam), _ inactiveTint: Color = .blue) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) {
                TabItem(tint: tint, inactiveTint: inactiveTint, tab: $0, animation: animation, activeTab: $activeTab, position: $tabShapePosition)
            }
        }
        .padding(.top, 15)
        .padding(.horizontal, 15)
        .padding(.bottom, -5)
        .background(content: {
            TabShape(midPoint: tabShapePosition.x)
            /// 탭바 Background 컬러
                .fill(.white)
            /// SafeArea 침범
                .ignoresSafeArea()
            /// Adding Blur + Shadow
            /// For Shape Smoothening (Shadow)
            /// radius 번짐 정도
                .shadow(color: tint.opacity(0.5), radius: 5, x: 0, y: -5)
                .padding(.top, 25) // 탭바 백그라운드 색상 위치
        })
        /// Adding Animation( Animation with Cricle)
        /// response: 반응속도
        /// dampingFraction: 감쇠율 (튕기는 정도)
        /// blendDuration: 기존 애니메이션과의 융화
        /// 기존애니매이션: .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7), value: activeTab)
    }
}

