//
//  ActivityModels.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import SwiftUI


enum MediaType {
    case media
    case image
    case unowned
}


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
    var mediaType: MediaType = .image
    
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

struct FilterActivityModel: ActivityModelBuildable, Identifiable {
    let id = UUID()
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
    var isKeep: Bool // 현재 유저의 킵 여부
    let keepCount: Int // 이 액티비티의 총 킵 수
    let endDate: String?
    var mediaType: MediaType = .image
    
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
    
    
    
    var eventTag: Tag? {
        
        guard let tag = tag else {
            return nil
        }
        if tag.hasPrefix("Hot") {
            return .hot
        } else if tag.hasPrefix("New") {
            return .new
        } else {
            return nil
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

