//
//  CustomTextEditor.swift
//  EzyBook
//
//  Created by youngkyun park on 8/17/25.
//

import SwiftUI




import SwiftUI

struct AutoResizingTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    
    var maxHeight: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 18)
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        // 크기 계산
        let size = uiView.sizeThatFits(CGSize(width: uiView.bounds.width,
                                              height: .greatestFiniteMagnitude))
        dynamicHeight = min(size.height, maxHeight)
        uiView.isScrollEnabled = size.height > maxHeight
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AutoResizingTextEditor
        init(parent: AutoResizingTextEditor) { self.parent = parent }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

import SwiftUI

struct CustomTextEditor: View {
    @Binding var text: String
    @State private var height: CGFloat = 14
    //@Binding private var isFocused: Bool

    // 폰트/줄수 설정
    private let uiFont =  UIFont(name: "Pretendard-Regular", size: 14)!
    private let maxLines = 4

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("메시지를 입력해주세요")
                    .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                    .padding(.top, 8)
                    .padding(.leading, 8)
            }

            // 4줄까지 자동 확장, 이후 내부 스크롤
            AutoGrowingTextEditor(text: $text, calculatedHeight: $height, maxLines: maxLines, font: uiFont)
                .frame(height: max(height, uiFont.lineHeight + 16)) // 초기 한 줄 높이 보장
        }
        .padding(5)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
    
    }
}
import SwiftUI

struct AutoGrowingTextEditor: View {
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var maxLines: Int = 4
    var font: UIFont

    var body: some View {
        // 가용 폭을 먼저 얻은 뒤 그 폭으로 sizeThatFits 계산
        GeometryReader { geo in
            AutoGrowingTextView(
                text: $text,
                calculatedHeight: $calculatedHeight,
                maxLines: maxLines,
                font: font,
                availableWidth: max(geo.size.width, 1) // 0 폭 방지
            )
        }
        .frame(minHeight: font.lineHeight + 16) // 최소 높이 (1줄 + 패딩)
    }
}

private struct AutoGrowingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    let maxLines: Int
    let font: UIFont
    let availableWidth: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.delegate = context.coordinator
        tv.font = font
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text { uiView.text = text }
        recalcHeight(view: uiView)
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    private func recalcHeight(view: UITextView) {
        // 레이아웃 초기에 폭이 0일 수 있으므로 가드
        guard availableWidth > 0 else { return }
        let fitting = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        let size = view.sizeThatFits(fitting)

        // 4줄 캡 (줄높이 * 줄수 + 텍스트 인셋)
        let cap = font.lineHeight * CGFloat(maxLines) + (view.textContainerInset.top + view.textContainerInset.bottom)

        let target = min(size.height, cap)
        if calculatedHeight != target {
            DispatchQueue.main.async { self.calculatedHeight = target }
        }
        // cap을 넘으면 내부 스크롤 허용
        view.isScrollEnabled = size.height > cap
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: AutoGrowingTextView
        init(parent: AutoGrowingTextView) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.recalcHeight(view: textView)
        }
    }
}
