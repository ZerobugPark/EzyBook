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
    
    let onFinish: () -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        startIamportPayment(in: webView)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func startIamportPayment(in webView: WKWebView) {
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
            dismiss()
        }
            
        
    }
}



