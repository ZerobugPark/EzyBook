//
//  PaymentEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation


struct ReceiptOrderEntity {
    let paymentId: String       // 결제 ID
    let orderItem: OrderEntity     // 주문 항목
    let createdAt: String
    let updatedAt: String
    
    
    init(dto: ReceiptOrderResponseDTO) {
        self.paymentId = dto.paymentId
        self.orderItem = OrderEntity.init(dto: dto.orderItem)
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
}



struct PaymentLookUpEntity {
    let impUid: String
    let merchantUid: String
    let payMethod: String?
    let channel: String?
    let pgProvider: String?
    let embPgProvider: String?
    let pgTid: String?
    let pgId: String?
    let escrow: Bool?
    let applyNum: String?
    let bankCode: String?
    let bankName: String?
    let cardCode: String?
    let cardName: String?
    let cardIssuerCode: String?
    let cardIssuerName: String?
    let cardPublisherCode: String?
    let cardPublisherName: String?
    let cardQuota: String?
    let cardNumber: String?
    let cardType: String?

    let vbankCode: String?
    let vbankName: String?
    let vbankNum: String?
    let vbankHolder: String?
    let vbankDate: Int?
    let vbankIssuedAt: Int?

    let name: String?
    let amount: Int
    let currency: String

    let buyerName: String?
    let buyerEmail: String?
    let buyerTel: String?
    let buyerAddr: String?
    let buyerPostcode: String?

    let customData: String?
    let userAgent: String?
    let status: String

    let startedAt: String?
    let paidAt: String?
    let receiptUrl: String?
    let createdAt: String?
    let updatedAt: String?
    
    init(dto: PaymentLookUpResponseDTO) {
        self.impUid = dto.impUid
        self.merchantUid = dto.merchantUid
        self.payMethod = dto.payMethod
        self.channel = dto.channel
        self.pgProvider = dto.pgProvider
        self.embPgProvider = dto.embPgProvider
        self.pgTid = dto.pgTid
        self.pgId = dto.pgId
        self.escrow = dto.escrow
        self.applyNum = dto.applyNum
        self.bankCode = dto.bankCode
        self.bankName = dto.bankName
        self.cardCode = dto.cardCode
        self.cardName = dto.cardName
        self.cardIssuerCode = dto.cardIssuerCode
        self.cardIssuerName = dto.cardIssuerName
        self.cardPublisherCode = dto.cardPublisherCode
        self.cardPublisherName = dto.cardPublisherName
        self.cardQuota = dto.cardQuota
        self.cardNumber = dto.cardNumber
        self.cardType = dto.cardType
        self.vbankCode = dto.vbankCode
        self.vbankName = dto.vbankName
        self.vbankNum = dto.vbankNum
        self.vbankHolder = dto.vbankHolder
        self.vbankDate = dto.vbankDate
        self.vbankIssuedAt = dto.vbankIssuedAt
        self.name = dto.name
        self.amount = dto.amount
        self.currency = dto.currency
        self.buyerName = dto.buyerName
        self.buyerEmail = dto.buyerEmail
        self.buyerTel = dto.buyerTel
        self.buyerAddr = dto.buyerAddr
        self.buyerPostcode = dto.buyerPostcode
        self.customData = dto.customData
        self.userAgent = dto.userAgent
        self.status = dto.status
        self.startedAt = dto.startedAt
        self.paidAt = dto.paidAt
        self.receiptUrl = dto.receiptUrl
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
}
