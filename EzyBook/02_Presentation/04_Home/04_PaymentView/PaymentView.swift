//
//  PaymentView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/11/25.
//

import SwiftUI
import UIKit
import WebKit
import iamport_ios


struct PaymentView: UIViewRepresentable {
    
    let item: PayItem
    let onFinish: (DisplayError?) -> Void
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: PaymentViewModel
    
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        startIamportPayment(in: webView)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func startIamportPayment(in webView: WKWebView) {
        
        /// INIpayTest - 아임포트가 제공하는 이니시스 테스트 상점 ID
        let payment = IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: item.orderCode,
            amount: item.price
        ).then {
            $0.name = item.name
            $0.buyer_name = item.buyerName
            $0.app_scheme = item.appScheme
        }
        
        Iamport.shared.paymentWebView(webViewMode: webView, userCode: item.userCode, payment: payment) { iamportResponse in
            print(String(describing: iamportResponse))
            
            guard let data = iamportResponse else {
                
                dismiss()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onFinish(DisplayError.error(code: -1, msg: iamportResponse?.error_msg ?? "알 수 없는 오류가 발생했습니다."))
                }
                
                return
            }
            
            
            if let success = data.success, success  {
                
                // 주의: imp_uid, merchant_uid도 옵셔널일 수 있음
                guard let impUid = data.imp_uid, let merchantUid = data.merchant_uid else {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onFinish(DisplayError.error(code: -1, msg: "imp 또는 merchant가 nil입니다."))
                    }
                    return
                }
                
                viewModel.action(.vaildation(impUid: impUid, merchantUid: merchantUid) { error in
                    dismiss()
                    onFinish(error)
                })
                
            } else {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onFinish(DisplayError.error(code: -1, msg: data.error_msg ?? "결제가 취소되었습니다."))
                }
                
            }
            
            
        }
        
    }
}
