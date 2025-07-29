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
    let image: UIImage
    let paidDate: String
    let price: Int

    
    init(
        orderID: String,
        orderCode: String,
        activityID: String,
        title: String?,
        country: String?,
        date: String,
        time: String,
        rating: Int?,
        image: UIImage,
        paidDate: String,
        price: Int
    ) {
        self.orderID = orderID
        self.orderCode = orderCode
        self.activityID = activityID
        self.title = title ?? ""
        self.country = country ?? ""
        self.date = date
        self.time = time
        self.rating = rating
        self.image = image
        self.paidDate = paidDate
        self.price = price
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
    let image: UIImage?
    
    init(dto: UserReviewEntity, image: UIImage?) {
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
        self.image = image
    }
}
