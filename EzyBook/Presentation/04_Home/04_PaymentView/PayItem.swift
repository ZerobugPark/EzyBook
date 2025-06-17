//
//  PayItem.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation

struct PayItem {
    
    let orderCode: String
    let price: String
    let name: String
    let buyerName = "박영균"
    let appScheme = "ezybook"
    let userCode = "imp14511373"
    
    init(orderCode: String, price: String, name: String) {
        self.orderCode = orderCode
        self.price = price
        self.name = name
    }
    
    
}
