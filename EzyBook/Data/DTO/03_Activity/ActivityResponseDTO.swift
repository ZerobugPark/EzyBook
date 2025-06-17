//
//  ActivityResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import Foundation

/// 액티비티 (요약) 목록 조회
/// 내가 킵한 액티비티 조회
struct ActivitySummaryListResponseDTO: Decodable, EntityConvertible {
    let data: [ActivitySummaryResponseDTO]
    let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

/// 액티비티 요약
struct ActivitySummaryResponseDTO: Decodable {
    let activityID: String // 고유 식별자
    let title: String? // 제목
    let country: String? // 국가
    let category: String? // 투어
    let thumbnails: [String] // 썸네일 이미지 경로
    let geolocation: ActivityGeolocationDTO // 위치
    let price: ActivityPriceDTO // 가격
    let tags: [String] // 태그 (ex. 오픈할인)
    let pointReward: Int? // 액티비티 포인트 리워드
    let isAdvertisement: Bool //광고 여부
    let isKeep: Bool // 현재 유저의 킵 여부
    let keepCount: Int // 이 액티비티의 총 킵 수
    
    enum CodingKeys: String, CodingKey {
        case activityID = "activity_id"
        case title
        case country
        case category
        case thumbnails
        case geolocation
        case price
        case tags
        case pointReward = "point_reward"
        case isAdvertisement = "is_advertisement"
        case isKeep = "is_keep"
        case keepCount = "keep_count"
    }
    
}

/// 액티비티 상세 조회
struct ActivityDetailResponseDTO: Decodable, EntityConvertible {
    let activityID: String // 고유 식별자
    let title: String? // 제목
    let country: String? // 국가
    let category: String? // 투어
    let thumbnails: [String] // 썸네일 이미지 경로
    let geolocation: ActivityGeolocationDTO // 위치
    let startDate: String? // 액비비티 운영 기간(시작)
    let endDate: String? // 액비비티 운영 기간(종료)
    let price: ActivityPriceDTO // 가격
    let tags: [String] // 태그 (ex. 오픈할인)
    let pointReward: Int // 액티비티 포인트 리워드
    let restrictions: ActivityRestrictionsDTO // 제한 사항
    let description: String? //설명
    let isAdvertisement: Bool //광고 여부
    let isKeep: Bool // 현재 유저의 킵 여부
    let keepCount: Int // 이 액티비티의 총 킵 수
    let totalOrderCount: Int // 총 주문 예약
    let schedule: [ActivityScheduleItemDTO] // 일정 정보
    let reservationList: [ActivityReservationItemDTO] // 예약 리스트
    let creator: ActivityCreatorDTO // 게시자
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case activityID = "activity_id"
        case title
        case country
        case category
        case thumbnails
        case geolocation
        case startDate = "start_date"
        case endDate = "end_date"
        case price
        case tags
        case pointReward = "point_reward"
        case restrictions
        case description
        case isAdvertisement = "is_advertisement"
        case isKeep = "is_keep"
        case keepCount = "keep_count"
        case totalOrderCount = "total_order_count"
        case schedule
        case reservationList = "reservation_list"
        case creator
        case createdAt
        case updatedAt
    }
    
}


/// // 액티비티 킵/ 킵 취소 작업 후 상태
struct ActivityKeepResponseDTO: Decodable, EntityConvertible {
    let keepStatus: Bool // 현재 액비비티에 대한 사용자의 킵 상태 (즉 킵을 하면 true가 리턴)
    
    enum CodingKeys: String, CodingKey {
        case keepStatus = "keep_status"
    }
}


/// New 액티비티 목록 조회
/// 액비티비 검색
struct ActivityListResponseDTO: Decodable, EntityConvertible {
    let data: [ActivitySummaryResponseDTO]
}


// MARK: 공통 DTO

/// 액티비티 위치
struct ActivityGeolocationDTO: Decodable {
    let longitude: Double // 경도
    let latitude: Double // 위도
}

/// 액티비티 가격
struct ActivityPriceDTO: Decodable {
    let original: Int // 원래 가격
    let final: Int // 최종 결제 가격
}


// MARK: 액티비티 상세

/// 액티비티  일정 정보
struct ActivityScheduleItemDTO: Decodable {
    let duration: String // 일정 소요 시간
    let description: String // 간단한 일정 소개
}



/// 액티비티  제약 사항
struct ActivityRestrictionsDTO: Decodable {
    let minHeight: Int // 최소 키 제한
    let minAge: Int // 최소 나이 제한
    let maxParticipants: Int // 최대 참가 인원
    
    enum CodingKeys: String, CodingKey {
        case minHeight = "min_height"
        case minAge = "min_age"
        case maxParticipants = "max_participants"
    }
    
}

/// 액티비티  예약 아이템 정보
struct ActivityReservationItemDTO: Decodable {
    let itemName: String // 예약 아이템 이름(날짜??)
    let times: [ActivityReservationTimeDTO] // 해당 아이템의 시간대별 예약 정보
    
    enum CodingKeys: String, CodingKey {
        case itemName = "item_name"
        case times
    }
}

/// 액티비티 시간대별 예약 정보
struct ActivityReservationTimeDTO: Decodable {
    let time: String // 예약 시간
    let isReserved: Bool // 예약 여부
    
    enum CodingKeys: String, CodingKey {
        case time
        case isReserved = "is_reserved"
    }
}


/// 액티비티 시간대별 예약 정보
struct ActivityCreatorDTO: Decodable {
    let userID: String
    let nick: String
    let introduction: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
        case introduction
    }
}
