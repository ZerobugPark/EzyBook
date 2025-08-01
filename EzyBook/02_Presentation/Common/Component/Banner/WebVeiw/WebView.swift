//
//  WebView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

   
    let tokenManger: TokenStorage
    let url: URL
    let onCompleteAttendance: ((String) -> Void)?
    
    ///WebView에서 자동 렌더링 (UIViewRepresentable)
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration() // WKWebView 초기 설정
        
        // 웹뷰 컨트롤러에 브릿지 받을 때 사용할 키워드
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "click_attendance_button")
        controller.add(context.coordinator, name: "complete_attendance")
        
        config.userContentController = controller
        
        // 웹뷰 설정
        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView
        
        
        //let url = URL(string: APIConstants.baseURL + "/event-application")!
        var request = URLRequest(url: url)
        request.addValue("\(APIConstants.apiKey)", forHTTPHeaderField: "SeSACKey")
        
        
        webView.load(request)
        return webView
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: WebView
        weak var webView: WKWebView?
        
        init(parent: WebView) {
            self.parent = parent
        }
        // 브릿지 통신 처리
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "click_attendance_button":
                //2. 출석 버튼 클릭 처리 후 액세스 토큰 전달 (Navite to Web)
                // evaluateJavaScript
                // '' : 자바 스크립트 내 문자열
                // "" : 스위프트에서 쓰는 문자열을 보내면 오류
                let token = parent.tokenManger.loadToken(key:KeychainKeys.accessToken)!
                webView?.evaluateJavaScript("requestAttendance('\(token)')") { result, error in
                    if let error = error {
                        print("JS 실행 오류: \(error)")
                    }
                }
            case "complete_attendance":
                //3. 출석 완료 처리(ex. 얼럿, 토스트, 뒤로가기 액션 등)
                Task { @MainActor in
                    
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    let result = String(describing: message.body)
                    parent.onCompleteAttendance?(result)
                }
                
                

                break
            default:
                break
            }
        }
    }
}

