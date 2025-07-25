//
//  TabItem.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import SwiftUI

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
                .foregroundStyle(activeTab == tab ? .white : inactiveTint)
                ///  Image Size
                .frame(width: activeTab == tab ? 50: 35, height: activeTab == tab ? 50: 35)
                
                .background {
                    if activeTab == tab {
                        Circle()
                            .fill(tint.gradient)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
            
            /// 추측. Text가 없으면 matchedGeometryEffect의 인식이 늦나?
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
            /// Animation With Path
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)) {
                position.x = tabPosition.x
            }
            
        }
                          
    }
}
