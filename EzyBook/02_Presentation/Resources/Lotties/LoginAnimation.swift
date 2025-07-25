//
//  LoginAnimation.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import SwiftUI
import Lottie
/// Lottie가 UIkit 기반이기 때문에, UIkit import 필요
import UIKit

struct LoginAnimation: UIViewRepresentable {
    
    var animationName : String
    var loopMode: LottieLoopMode
    
    init(animationName: String, loopMode: LottieLoopMode = .loop) {
        self.animationName = animationName
        self.loopMode = loopMode
    }
    
    /// makeUIView(context:)
    /// 이 함수는 SwiftUI가 뷰를 처음 만들 때 자동 호출
    func makeUIView(context: UIViewRepresentableContext<LoginAnimation>) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: animationName)
        
        // MARK: Congifuration Animation

        // 애니메이션은 루프 설정
        animationView.loopMode = loopMode
        // AspectFit으로 적절한 크기의 에니매이션을 불러옵니다.
       animationView.contentMode = .scaleAspectFit
    
       animationView.loopMode = loopMode
        // Play Animation
        animationView.play()
        // 백그라운드에서 재생이 멈추는 오류를 잡습니다
        animationView.backgroundBehavior = .pauseAndRestore

     ///컨테이너의 너비와 높이를 자동으로 지정할 수 있도록합니다. 로티는 컨테이너 위에 작성
      animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
         //레이아웃의 높이와 넓이의 제약
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    /// SwiftUI가 @State, @Binding, 외부 값의 변화를 감지하면 이 메서드를 호출해서 뷰를 업데이트
    /// 이미 만들어진 UIView를 수정하거나, 재설정할 때 사용
    // 값이 변경될 때마다 자동 호출돼.
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
   
}

