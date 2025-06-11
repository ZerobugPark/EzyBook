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


struct PaymentView: UIViewControllerRepresentable {
    @StateObject var viewModel: PayMentViewModel
    @Environment(\.dismiss) private var dismiss
    
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = PaymentViewController()
        vc.viewModel = viewModel
        
        vc.onDismiss = {
            dismiss()
          }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

class PaymentViewController: UIViewController, WKNavigationDelegate {
    var viewModel: PayMentViewModel? = nil
    var onDismiss: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PaymentView viewDidLoad")

        view.backgroundColor = UIColor.blue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PaymentView viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PaymentView viewDidAppear")
        requestPayment()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("PaymentView viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("PaymentView viewDidDisappear")
    }


    // 아임포트 SDK 결제 요청
    func requestPayment() {
        guard let viewModel = viewModel else {
            print("viewModel 이 존재하지 않습니다.")
            return
        }

        let userCode = viewModel.order.userCode // iamport 에서 부여받은 가맹점 식별코드
        if let payment = viewModel.createPaymentData() {
            dump(payment)

//          #case1 use for UIViewController
//          WebViewController 용 닫기버튼 생성(PG "uplus(토스페이먼츠 구모듈)"는 자체취소 버튼이 없는 것으로 보임)
            Iamport.shared.useNavigationButton(enable: true)

            Iamport.shared.payment(viewController: self,
                userCode: userCode.value, payment: payment) { response in
                viewModel.iamportCallback(response)
                self.onDismiss?()
                
            }

//          #case2 use for navigationController
//          guard let navController = navigationController else {
//              print("navigationController 를 찾을 수 없습니다")
//              return
//          }
//
//          Iamport.shared.payment(navController: navController,
//              userCode: userCode.value, iamportRequest: request) { iamportResponse in
//              viewModel.iamportCallback(iamportResponse)
//          }
        }
    }

}


