//
//  TapShape.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import SwiftUI

struct TabShape: Shape {
    var midPoint: CGFloat
    
    /// Adding Shape Animation
    /// animatableData는 SwiftUI에서 Animatable 프로토콜에 의해 "정해진 이름"이야.
    // 즉, 무조건 이 이름을 써야 SwiftUI가 애니메이션할 수 있는 값으로 인식
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
            
            /// 왼쪽 -> 중앙
            let to = CGPoint(x: midPoint, y: -25)
            let control1 = CGPoint(x:midPoint - 25, y: 0)
            let control2 = CGPoint(x: midPoint - 25, y: -25)
            //print(midPoint)
            
            ///to 도착지
            ///control1 은 곡선이 ‘출발’할 때의 기울기
            ///control2 는 곡선이 ‘도착’할 때의 기울기
            path.addCurve(to: to, control1: control1, control2: control2)
            
            /// 중앙 -> 오른쪽
            let to1 = CGPoint(x: midPoint + 60, y: 0)
            let control3 = CGPoint(x:midPoint + 25, y: -25)
            let control4 = CGPoint(x: midPoint + 25, y: 0)
            
            path.addCurve(to: to1, control1: control3, control2: control4)
        }
    }
}
