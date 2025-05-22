//
//  MainTabView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI


enum Tab: String, CaseIterable {
    case home = "Home"
    case services = "Services"
    case postGallery = "PostGallery"
    case profile = "Profile"
    
    var tabImage: Image {
        switch self {
        case .home:
                .init(.tabBarHomeFill)
        case .services:
                .init(.tabBarFrameEmpty)
        case .postGallery:
                .init(.tabBarHomeFill)
        case .profile:
                .init(.tabBarHomeFill)
        }
    }
    
    var  index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}

struct MainTabView: View {
    
    @State private var activeTab: Tab = .home
    
    /// For Smooth Shape Sliding Effect, We're going to use Matched Geometry
    @Namespace private var animation
    @State private var tabShapePosition: CGPoint = .zero
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
        
                Text("Home")
                    .tag(Tab.home)
                    ///Hiding Native Tab Bar
                    //.toolbar(.hidden, for: .tabBar)
                
                Text("Services")
                    .tag(Tab.services)
                    ///Hiding Native Tab Bar
                    //.toolbar(.hidden, for: .tabBar)
                
                Text("PostGallery")
                    .tag(Tab.postGallery)
                    ///Hiding Native Tab Bar
                    //.toolbar(.hidden, for: .tabBar)
                
                Text("Profile")
                    .tag(Tab.profile)
                    ///Hiding Native Tab Bar
                   // .toolbar(.hidden, for: .tabBar)
            }
        }
        
        CustomTabbar()
    }
    
    
    /// Custome Tab Bar
    /// With More Easy Customization
    @ViewBuilder
    func CustomTabbar(_ tint: Color = Color(.blue), _ inactiveTinit: Color = .blue) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) {
                TabItem(tint: tint, inactiveTint: inactiveTinit, tab: $0, animation: animation, activeTab: $activeTab, position: $tabShapePosition)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(content: {
            TabShape(midPoint: tabShapePosition.x)
            /// 탭바 Background 컬러
                .fill(.white)
                .ignoresSafeArea()
            /// Adding Blur + Shadow
            /// For Shape Smoothening
                .shadow(color: tint.opacity(0.5), radius: 5, x: 0, y: -5)
                .padding(.top, 25)
        })
        /// Adding Animation
        /// response: 반응속도
        /// dampingFraction: 감쇠율 (튕기는 정도)
        /// blendDuration: 기존 애니메이션과의 융화
        /// 기존애니매이션: .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7), value: activeTab)
    }
}

/// Tab Bar Item
struct TabItem: View {
    
    var tint: Color
    var inactiveTint: Color
    var tab: Tab
    var animation: Namespace.ID
    
    @Binding var activeTab: Tab
    @Binding var position: CGPoint
    
    ///Each Tab Item Position on the Screen
    @State private var tabPosition: CGPoint = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            tab.tabImage
                .font(.title2)
                .foregroundStyle(activeTab == tab ? .white : inactiveTint)
                .frame(width: activeTab == tab ? 50: 35, height: activeTab == tab ? 50: 35)
                .background {
                    if activeTab == tab {
                        Circle()
                            .fill(tint.gradient)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
            
            Text(tab.rawValue)
                .font(.caption)
                .foregroundStyle( activeTab == tab ? tint : .gray)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .viewPosition(completionHandler: { rect in
            tabPosition.x = rect.midX
            
            ///Updating Active Tab Position
            if activeTab == tab {
                position.x = rect.midX
            }
        })
        .onTapGesture {
            activeTab = tab
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)) {
                position.x = tabPosition.x
            }
            
        }
                          
    }
}

#Preview {
    MainTabView()
}


struct TabShape: Shape {
    var midPoint: CGFloat
    
    /// Adding Shape Animation
    /// animatableData는 SwiftUI에서 Animatable 프로토콜에 의해 "정해진 이름"이야.
    /// 즉, 무조건 이 이름을 써야 SwiftUI가 애니메이션할 수 있는 값으로 인식
    var animatableData: CGFloat {
        get { midPoint }
        set {
            midPoint = newValue
        }
    }
    func path(in rect: CGRect) -> Path {
        return Path { path in
            /// First Drawing the Rectangle Shape
            path.addPath(Rectangle().path(in: rect))
            /// Now Drawing Upward Curve Shape
            path.move(to: .init(x: midPoint - 60, y: 0))
            
            let to = CGPoint(x: midPoint, y: -25)
            let control1 = CGPoint(x:midPoint - 25, y: -0)
            let control2 = CGPoint(x: midPoint - 25, y: -25)
            
            path.addCurve(to: to, control1: control1, control2: control2)
            
            let to1 = CGPoint(x: midPoint + 60, y: 0)
            let control3 = CGPoint(x:midPoint + 25, y: -25)
            let control4 = CGPoint(x: midPoint + 25, y: 0)
            
            path.addCurve(to: to1, control1: control3, control2: control4)
        }
    }
}



/// Custom View Extension
/// Witch will Return View Position
///
struct PositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value  = nextValue()
    }
}

extension View {
    @ViewBuilder
    func viewPosition(completionHandler: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let rect = $0.frame(in: .global)
                    
                    Color.clear
                        .preference(key: PositionKey.self, value: rect)
                        .onPreferenceChange(PositionKey.self, perform: completionHandler)
                }
            }
    }
}
