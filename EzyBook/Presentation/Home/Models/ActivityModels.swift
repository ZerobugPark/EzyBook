//
//  ActivityModels.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI


protocol ActivityModelBuildable {
    init(from detail: ActivityDetailEntity, thumbnail: UIImage)
}


struct NewActivityModel: ActivityModelBuildable {
    
    let activityID: String
    let title: String
    let country: String
    let thumnail: UIImage
    let tag: String?
    let description: String
    let originalPrice: Int
    let finalPrice: Int
    
    
    // 금액이 다를 경우 어떻게 비교를 해줄까?
    
    init (from detail: ActivityDetailEntity, thumbnail: UIImage) {
        self.activityID = detail.activityID
        self.title = detail.title
        self.country =  detail.country
        self.thumnail =  thumbnail
        self.tag = detail.tags.isEmpty ? nil : detail.tags[0]
        self.description = detail.description
        self.originalPrice = detail.price.original
        self.finalPrice = detail.price.final
        
    }
    
}

struct FilterActivityModel: ActivityModelBuildable {
    
    let activityID: String
    let title: String
    let country: String
    let thumnail: UIImage
    let tag: String?
    let description: String
    let originalPrice: Int
    let finalPrice: Int
    let pointReward: Int? // 액티비티 포인트 리워드
    let isAdvertisement: Bool //광고 여부
    let isKeep: Bool // 현재 유저의 킵 여부
    let keepCount: Int // 이 액티비티의 총 킵 수
    let endDate: String?
    
    var isDiscount: Bool {
        originalPrice != finalPrice
    }
    
    var discountRate: String {
        if isDiscount {
            let discountRate = 100 - ceil(Double(finalPrice) / Double(originalPrice) * 100)
            let formatted = discountRate.formattedPercentage()
            return "\(formatted)%"
        } else {
            return ""
        }
    }
    
    /// New Activity가 마감 임박일 수 있을까?
    var isNewActiviy: Bool {
        
        guard let tag = tag else {
            return false
        }
        
        if tag == "New 오픈특가" {
            return true
        } else {
            return false
        }
  
    }
    
    init(from detail: ActivityDetailEntity, thumbnail: UIImage) {
        self.activityID = detail.activityID
        self.title = detail.title
        self.country = detail.country
        self.thumnail = thumbnail
        self.tag = detail.tags.isEmpty ? nil : detail.tags[0]
        self.description = detail.description
        self.originalPrice = detail.price.original
        self.finalPrice = detail.price.final
        self.pointReward = detail.pointReward
        self.isAdvertisement = detail.isAdvertisement
        self.isKeep = detail.isKeep
        self.keepCount = detail.keepCount
        self.endDate = detail.endDate
    }
    

}

