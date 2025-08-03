//
//  03_ActivityPostEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import Foundation

struct PostSummaryPaginationEntity {
    
    let data: [PostSummaryEntity]
    let nextCursor: String
    
    init(dto: PostSummaryPaginationResponseDTO) {
        self.data = dto.data.map { PostSummaryEntity(dto: $0) }
        self.nextCursor = dto.nextCursor
    }
}


struct PostSummaryEntity: Identifiable {
    var id = UUID()
    
    let postID: String
    let country: String
    let category: String
    let title: String
    let content: String
    let activity: ActivitySummaryEntity_Post?
    let geolocation: GeolocationEntity
    let creator: UserInfoEntity
    let files: [String]
    let isLike: Bool
    let likeCount: Int
    let createdAt: String
    let updatedAt: String
    
    init(dto: PostSummaryResponseDTO) {
        self.postID = dto.postID
        self.country = dto.country
        self.category = dto.category
        self.title = dto.title
        self.content = dto.content
        self.activity =  dto.activity.map { ActivitySummaryEntity_Post(dto: $0) }
        self.geolocation = GeolocationEntity(dto: dto.geolocation)
        self.creator = UserInfoEntity(dto: dto.creator)
        self.files = dto.files
        self.isLike = dto.isLike
        self.likeCount = dto.likeCount
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
    
}
extension PostSummaryEntity {
    
    var relativeTimeDescription: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: createdAt) else {
            return "알 수 없음"
        }

        let now = Date()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)

        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)달 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
}


struct GeolocationEntity {
    let longitude: Float
    let latitude: Float
    
    init(dto: Geolocation) {
        self.longitude = dto.longitude
        self.latitude = dto.latitude
    }
}

struct PostEntity {
    let postID: String
    let country: String
    let category: String
    let title: String
    let content: String
    let activity: ActivitySummaryEntity_Post?
    let geolocation: GeolocationEntity
    let creator: UserInfoEntity
    var files: [String]
    let isLike: Bool
    let likeCount: Int
    let comments: [CommentEntity]
    let createdAt: String
    let updatedAt: String
    
    init(dto: PostResponseDTO) {
        self.postID = dto.postID
        self.country = dto.country
        self.category = dto.category
        self.title = dto.title
        self.content = dto.content
        self.activity =   dto.activity.map {ActivitySummaryEntity_Post(dto: $0) }
        self.geolocation =  GeolocationEntity(dto: dto.geolocation)
        self.creator = UserInfoEntity(dto: dto.creator)
        self.files = dto.files
        self.isLike = dto.isLike
        self.likeCount = dto.likeCount
        self.comments =  dto.comments.map { CommentEntity(dto: $0) }
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
}

extension PostEntity {
    func with(files: [String]) -> PostEntity {
        var copy = self
        copy.files = files
        return copy
    }
    
    var relativeTimeDescription: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: createdAt) else {
            return "알 수 없음"
        }

        let now = Date()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)

        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)달 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
}



// MARK:  Mock Data
extension PostEntity {
    
    static let skeleton = PostEntity(
        dto: PostResponseDTO(
            postID: "",
            country: "",
            category: "",
            title: "",
            content: "",
            activity: nil,
            geolocation: Geolocation(longitude: 0.0, latitude: 0.0),
            creator: UserInfoResponseDTO(userID: "", nick: "", profileImage: nil, introduction: nil),
            files: [],
            isLike: false,
            likeCount: 0,
            comments: [CommentResponseDTO(
                commentID: "",
                content: "",
                createdAt: "",
                creator: UserInfoResponseDTO(userID: "", nick: "", profileImage: nil, introduction: nil),
                replies: [ReplyResponseDTO(
                    commentID: "",
                    content: "",
                    createdAt: "",
                    creator: UserInfoResponseDTO(
                        userID: "",
                        nick: "",
                        profileImage: nil,
                        introduction: nil
                    )
                )]
            )],
            createdAt: "",
            updatedAt: ""
        )
    )
    
}


struct ActivitySummaryEntity_Post {
    let id: String
    let title: String?
    let country: String?
    let category: String?
    let thumbnails: [String]
    let geolocation: ActivityGeolocationEntity
    let price: ActivityPriceEntity
    let tags: [String]
    let pointReward: Int
    let isAdvertisement: Bool
    let isKeep: Bool
    let keepCount: Int
    
    init(dto: ActivitySummaryResponseDTO_Post) {
        self.id = dto.id
        self.title = dto.title
        self.country = dto.country
        self.category = dto.category
        self.thumbnails = dto.thumbnails
        self.geolocation =  ActivityGeolocationEntity(dto: dto.geolocation)
        self.price = ActivityPriceEntity(dto: dto.price)
        self.tags = dto.tags
        self.pointReward = dto.pointReward
        self.isAdvertisement = dto.isAdvertisement
        self.isKeep = dto.isKeep
        self.keepCount = dto.keepCount
    }

}

struct PostKeepEntity {
    let likeStatus: Bool
    
    init(likeStatus: Bool) {
        self.likeStatus = likeStatus
    }
}

struct CommentEntity {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: UserInfoEntity
    let replise: [ReplyEntity]
    
    init(dto: CommentResponseDTO) {
        self.commentID = dto.commentID
        self.content = dto.content
        self.createdAt = dto.createdAt
        self.creator =  UserInfoEntity(dto: dto.creator)
        self.replise = dto.replies.map { ReplyEntity(dto: $0) }
    }
}



struct ReplyEntity {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: UserInfoEntity
    
    init(dto: ReplyResponseDTO) {
        self.commentID = dto.commentID
        self.content = dto.content
        self.createdAt = dto.createdAt
        self.creator = UserInfoEntity(dto: dto.creator)
    }
}


struct FileResponseEntity {
    
    let files: [String]
    
    
    init(dto : FileResponseDTO) {
        self.files = dto.files
    }
}
