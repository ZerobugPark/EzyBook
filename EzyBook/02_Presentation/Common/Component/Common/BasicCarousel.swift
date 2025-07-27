//
//  BasicCarousel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import SwiftUI

struct BasicCarousel<Content: View>: View {
    
    typealias PageIndex = Int
    
    let pageCount: Int
    let visibleEdgeSpace: CGFloat
    let spacing: CGFloat
    let onPageChanged: ((Int) -> Void)?
    let content: (PageIndex) -> Content

    @State private var dragOffset: CGFloat = 0
    @State var currentIndex: Int = 0 {
        didSet {
            onPageChanged?(currentIndex)
        }
    }
    
    
    init(pageCount: Int, visibleEdgeSpace: CGFloat, spacing: CGFloat, onPageChanged: ((Int) -> Void)? = nil, @ViewBuilder content: @escaping (PageIndex) -> Content) {
        self.pageCount = pageCount
        self.visibleEdgeSpace = visibleEdgeSpace
        self.spacing = spacing
        self.onPageChanged = onPageChanged
        self.content = content
        
    }
    
    var body: some View {
        GeometryReader { proxy in
            let baseOffset: CGFloat = spacing + visibleEdgeSpace
            let pageWidth: CGFloat = proxy.size.width - (visibleEdgeSpace + spacing) * 2
            let offsetX: CGFloat = baseOffset + CGFloat(currentIndex) * -pageWidth + CGFloat(currentIndex) * -spacing + dragOffset
            
            HStack(spacing: spacing) {
                ForEach(0..<pageCount, id: \.self) { pageIndex in
                    let distance = abs(currentIndex - pageIndex)
                    let scale = max(0.85, 1.0 - CGFloat(distance) * 0.1)

                    self.content(pageIndex)
                        .scaleEffect(scale)
                        .frame(
                            width: pageWidth,
                            height: proxy.size.height
                        )
                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    
                }
                .contentShape(Rectangle())
            }
            .offset(x: offsetX)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        
                        let offsetX = value.translation.width
                        let threshold: CGFloat = 50
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if offsetX > threshold {
                                currentIndex = max(currentIndex - 1, 0)
                            } else if offsetX < -threshold {
                                currentIndex = min(currentIndex + 1, pageCount - 1)
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
    }
}


