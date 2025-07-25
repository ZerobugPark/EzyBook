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

    
    init(
        orderID: String,
        orderCode: String,
        activityID: String,
        title: String?,
        country: String?,
        date: String,
        time: String,
        rating: Int?,
        image: UIImage
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
    }
    
    var hasRating: Bool {
        rating != nil
    }
    
}
