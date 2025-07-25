//
//  PaymentResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation




/// 결제 검증
struct ReceiptOrderResponseDTO: Decodable, EntityConvertible {
    let paymentId: String       // 결제 ID
    let orderItem: OrderResponseDTO     // 주문 항목
    let createdAt: String
    let updatedAt: String
    
    
    enum CodingKeys: String, CodingKey {
        case paymentId = "payment_id"
        case orderItem = "order_item"
        case createdAt
        case updatedAt
    }
}



/// 결제 영수증 조회
struct PaymentLookUpResponseDTO: Decodable, EntityConvertible {
    let impUid: String  // 포트원 거래고유 번호
    let merchantUid: String // 고객사 주문번호
    let payMethod: String? // 결제수단 구분 코드
    let channel: String? // 결제환경 구분 코드
    let pgProvider: String? // PG사 구분 코드
    let embPgProvider: String? // 허브형 결제 PG사 구분 코드
    let pgTid: String? // PG사 거래번호
    let pgId: String? // PG사 상점 아이디
    let escrow: Bool? // 에스크로결제 여부
    let applyNum: String? // 승인번호
    let bankCode: String? // 은행 표준 코드
    let bankName: String? // 은행명
    let cardCode: String? // 카드사 코드번호
    let cardName: String? // 카드사명
    let cardIssuerCode: String? // 카드사 발급 번호
    let cardIssuerName: String? // 카드 발급사명
    let cardPublisherCode: String? // 카드 발생사 코드
    let cardPublisherName: String? // 카드 발행사 명
    let cardQuota: String? // 할부개월
    let cardNumber: String? // 카드번호
    let cardType: String? // 카드 구분코드

    let vbankCode: String? // 가상계좌 은행 표준코드
    let vbankName: String? // 가상계좌 은행명
    let vbankNum: String? // 가상계좌 계좌번호
    let vbankHolder: String? // 가상계좌 예금주
    let vbankDate: Int? // 가상계좌 입금 기한 (timestamp)
    let vbankIssuedAt: Int? // 가상계좌 생성 시간 (timestamp)

    let name: String? // 제품명
    let amount: Int // 결제 금액
    let currency: String // 결제 통화구분 코드

    let buyerName: String? // 주문자명
    let buyerEmail: String? // 주문자 email주소
    let buyerTel: String? // 주문자 전화번호
    let buyerAddr: String? // 주문자 주소
    let buyerPostcode: String? // 주문자 우편번호

    let customData: String? // 추가정보
    let userAgent: String? // 단말기의 UserAgent 문자열
    let status: String // 결제상태

    let startedAt: String? // 요청시간
    let paidAt: String? // 결제 시각
    let receiptUrl: String? // 매출 전표 URL
    let createdAt: String? // 생성시간
    let updatedAt: String? // 수정시간

    enum CodingKeys: String, CodingKey {
        case impUid = "imp_uid"
        case merchantUid = "merchant_uid"
        case payMethod = "pay_method"
        case channel
        case pgProvider = "pg_provider"
        case embPgProvider = "emb_pg_provider"
        case pgTid = "pg_tid"
        case pgId = "pg_id"
        case escrow
        case applyNum = "apply_num"
        case bankCode = "bank_code"
        case bankName = "bank_name"
        case cardCode = "card_code"
        case cardName = "card_name"
        case cardIssuerCode = "card_issuer_code"
        case cardIssuerName = "card_issuer_name"
        case cardPublisherCode = "card_publisher_code"
        case cardPublisherName = "card_publisher_name"
        case cardQuota = "card_quota"
        case cardNumber = "card_number"
        case cardType = "card_type"
        case vbankCode = "vbank_code"
        case vbankName = "vbank_name"
        case vbankNum = "vbank_num"
        case vbankHolder = "vbank_holder"
        case vbankDate = "vbank_date"
        case vbankIssuedAt = "vbank_issued_at"
        case name
        case amount
        case currency
        case buyerName = "buyer_name"
        case buyerEmail = "buyer_email"
        case buyerTel = "buyer_tel"
        case buyerAddr = "buyer_addr"
        case buyerPostcode = "buyer_postcode"
        case customData = "custom_data"
        case userAgent = "user_agent"
        case status
        case startedAt
        case paidAt
        case receiptUrl = "receipt_url"
        case createdAt
        case updatedAt
    }
}
