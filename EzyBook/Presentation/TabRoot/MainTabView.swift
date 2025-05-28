//
//  MainTabView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI


enum Tab: String, CaseIterable {
    case home = "Home"
    case reviews = "Reviews"
    case chat = "Chat"
    case profile = "Profile"
    
    var tabImage: Image {
        switch self {
        case .home:
                .init(.tabBarHomeEmpty)
        case .reviews:
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
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    init() {
        /// TabBar Hidden이 안될 때,
        //UITabBar.appearance().isHidden = true
    }
    
    var title: some View {
        Text("EzyBook")
            .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam) 
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                NavigationStack(path: $homeCoordinator.path) {
                    HomeView(viewModel: container.makeHomeViewModel())
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                title
                            }

                            ToolbarItem(placement: .topBarTrailing) {
                                HStack(alignment: .center, spacing: 0) {
                                    makeAlarmButton()
                                    makeKeppButton()
                                }
                            }
                            
                        }
                        .tag(Tab.home)
                    ///Hiding Native Tab Bar
                        .toolbar(.hidden, for: .tabBar)
                }
                
                Text("Services")
                    .tag(Tab.reviews)
                    ///Hiding Native Tab Bar
                    .toolbar(.hidden, for: .tabBar)
                
                Text("PostGallery")
                    .tag(Tab.chat)
                    ///Hiding Native Tab Bar
                    .toolbar(.hidden, for: .tabBar)
                
                ProfileView()
                    .tag(Tab.profile)
                    ///Hiding Native Tab Bar
                    .toolbar(.hidden, for: .tabBar)
            }
            .background(.red)
        }
        
        CustomTabbar()
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
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
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
                .padding(.top, 25)
        })
        /// Adding Animation( Animation with Cricle)
        /// response: 반응속도
        /// dampingFraction: 감쇠율 (튕기는 정도)
        /// blendDuration: 기존 애니메이션과의 융화
        /// 기존애니매이션: .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7), value: activeTab)
    }
}



#Preview {
    PreViewHelper.makeMainTabView()
}


extension MainTabView {
    
    func makeAlarmButton() -> some View {
        Button {
            print("text heart")
        } label: {
            Image(.iconNoti)
        }
    }
    
    func makeKeppButton() -> some View {
        
        Button {
            print("test heart")
        } label: {
            Image(.iconLikeEmpty)
        }

    }
}
