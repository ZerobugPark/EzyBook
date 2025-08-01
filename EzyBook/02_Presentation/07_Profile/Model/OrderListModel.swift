//
//  OrderListModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/19/25.
//

import SwiftUI


struct OrderList: Identifiable {
    
    var id: String { orderID } 
    
    let orderID: String
    let orderCode: String
    let activityID: String
    let title: String
    let country: String
    let date: String
    let time: String
    var rating: Int?
    let imagePath: String
    let paidDate: String
    let price: Int

    
    init(
        entitiy: OrderEntity
    ) {
        self.orderID = entitiy.orderId
        self.orderCode = entitiy.orderCode
        self.activityID = entitiy.activity.id
        self.title = entitiy.activity.title ?? ""
        self.country =  entitiy.activity.country ?? ""
        self.date = entitiy.reservationItemName
        self.time = entitiy.reservationItemTime
        self.rating = entitiy.review?.rating
        self.imagePath = entitiy.activity.thumbnails[0]
        self.paidDate = entitiy.paidAt
        self.price =  entitiy.totalPrice
    }
    

    
    var hasRating: Bool {
        rating != nil
    }
    
}



struct UserReviewDetailList {
    let reviewID: String
    let content: String
    let rating: Int
    let activityID: String
    var title: String
    let reviewImageURLs: [String]
    let reservationItemName: String
    let reservationItemTime: String
    let creator: UserInfoResponseEntity
    let createdAt: String
    let updatedAt: String
    
    init(dto: UserReviewEntity) {
        self.reviewID = dto.reviewID
        self.content = dto.content
        self.rating = dto.rating
        self.activityID =  dto.activity.id
        self.title = dto.activity.title ?? ""
        self.reviewImageURLs = dto.reviewImageURLs
        self.reservationItemName = dto.reservationItemName
        self.reservationItemTime = dto.reservationItemTime
        self.creator = dto.creator
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
}
