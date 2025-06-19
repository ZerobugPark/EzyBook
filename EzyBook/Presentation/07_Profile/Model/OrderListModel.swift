//
//  OrderListModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/19/25.
//

import SwiftUI


struct OrderList {
    
    let orderID: String
    let activityID: String
    let title: String
    let country: String
    let date: String
    let time: String
    let rating: Double? // 리뷰 ID가 있어야 할까??
    let price: Int
    let image: UIImage

    
    init(
        orderID: String,
        activityID: String,
        title: String?,
        country: String?,
        date: String,
        time: String,
        rating: Double?,
        price: Int,
        image: UIImage
    ) {
        self.orderID = orderID
        self.activityID = activityID
        self.title = title ?? ""
        self.country = country ?? ""
        self.date = date
        self.time = time
        self.rating = rating
        self.price = price
        self.image = image
    }
    
    var hasRating: Bool {
        rating != nil
    }
    
}
