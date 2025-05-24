//
//  ActivityEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation
import MapKit

/// 액티비티 목록 조회
/// 내가 킵한 액티비티 조회
///
///

struct ActivitySummaryListEntity {
    let data: [ActivitySummaryEntity]
    let nextCursor: String
    
    /// 쓸지는 모르겠지만 일단 Keep
    var hasNextPage: Bool {
        return nextCursor.isEmpty
    }
    
    init(dto: ActivitySummaryListResponseDTO) {
        self.data = dto.data.map { ActivitySummaryEntity.init(dto: $0) }
        self.nextCursor = dto.nextCursor
    }
}

/// New 액티비티 목록 조회
/// 액비티비 검색
struct ActivitySummaryEntity {
    let activityID: String // 고유 식별자
    let title: String // 제목
    let country: String // 국가
    let category: String // 투어
    let thumbnails: [String] // 썸네일 이미지 경로
    let geolocation: ActivityGeolocationEntity // 위치
    let price: ActivityPriceEntity // 가격
    let tags: [String] // 태그 (ex. 오픈할인)
    let pointReward: Int // 액티비티 포인트 리워드
    let isAdvertisement: Bool //광고 여부
    let isKeep: Bool // 현재 유저의 킵 여부
    let keepCount: Int // 이 액티비티의 총 킵 수
    
    init(dto: ActivitySummaryResponseDTO) {
        self.activityID = dto.activityID
        self.title = dto.title ?? ""
        self.country = dto.country ?? ""
        self.category = dto.category ?? ""
        self.thumbnails = dto.thumbnails
        self.geolocation = ActivityGeolocationEntity(dto: dto.geolocation)
        self.price = ActivityPriceEntity.init(dto: dto.price)
        self.tags = dto.tags
        self.pointReward = dto.pointReward ?? 0
        self.isAdvertisement = dto.isAdvertisement
        self.isKeep = dto.isKeep
        self.keepCount = dto.keepCount
    }
    
}




/// 액티비티 상세 조회
struct ActivityDetailEntity {
    let activityID: String // 고유 식별자
    let title: String // 제목
    let country: String // 국가
    let category: String // 투어
    let thumbnails: [String] // 썸네일 이미지 경로
    let geolocation: ActivityGeolocationEntity // 위치
    let startDate: String // 액비비티 운영 기간(시작)
    let endDate: String? // 액비비티 운영 기간(종료)
    let price: ActivityPriceEntity // 가격
    let tags: [String] // 태그 (ex. 오픈할인)
    let pointReward: Int // 액티비티 포인트 리워드
    let restrictions: ActivityRestrictionsEntity // 제한 사항
    let description: String //설명
    let isAdvertisement: Bool //광고 여부
    let isKeep: Bool // 현재 유저의 킵 여부
    let keepCount: Int // 이 액티비티의 총 킵 수
    let totalOrderCount: Int // 총 주문 예약
    let schedule: ActivityScheduleItemEntity // 일정 정보
    let reservationList: ActivityReservationItemEntity // 예약 리스트
    let creator: UserInfoResponseEntity // 게시자
    let createdAt: String
    let updateddAt: String
    
    init(dto: ActivityDetailResponseDTO) {
        self.activityID = dto.activityID
        self.title = dto.title ?? ""
        self.country = dto.country ?? ""
        self.category = dto.category ?? ""
        self.thumbnails = dto.thumbnails
        self.geolocation = ActivityGeolocationEntity(dto: dto.geolocation)
        self.startDate = dto.startDate ?? ""
        self.endDate = dto.endDate ?? ""
        self.price = ActivityPriceEntity.init(dto: dto.price)
        self.tags = dto.tags
        self.pointReward = dto.pointReward
        self.restrictions = ActivityRestrictionsEntity(dto: dto.restrictions)
        self.description = dto.description ?? ""
        self.isAdvertisement = dto.isAdvertisement
        self.isKeep = dto.isKeep
        self.keepCount = dto.keepCount
        self.totalOrderCount = dto.totalOrderCount
        self.schedule = ActivityScheduleItemEntity(dto: dto.schedule)
        self.reservationList = ActivityReservationItemEntity(dto: dto.reservationList)
        self.creator = UserInfoResponseEntity(dto: dto.creator)
        self.createdAt = dto.createdAt
        self.updateddAt = dto.updateddAt
    }

}


/// // 액티비티 킵/ 킵 취소 작업 후 상태
struct ActivityKeepEntity {
    let keepStatus: Bool // 현재 액비비티에 대한 사용자의 킵 상태 (즉 킵을 하면 true가 리턴)
}




// MARK: 공통 Entity

/// 액티비티 위치
struct ActivityGeolocationEntity {
    let longitude: Double // 경도
    let latitude: Double // 위도
    
    var asCLLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(dto: ActivityGeolocationDTO) {
        self.longitude = dto.longitude
        self.latitude = dto.latitude
    }
}

/// 액티비티 가격
struct ActivityPriceEntity {
    let original: Int // 원래 가격
    let final: Int // 최종 결제 가격
    
    init(dto: ActivityPriceDTO) {
        self.original = dto.original
        self.final = dto.final
    }
}


// MARK: 액티비티 상세
/// 액티비티  일정 정보
struct ActivityScheduleItemEntity {
    let duration: String // 일정 소요 시간
    let description: String // 간단한 일정 소개
    
    init(dto: ActivityScheduleItemDTO) {
        self.duration = dto.duration
        self.description = dto.description
    }
}



/// 액티비티  제약 사항
struct ActivityRestrictionsEntity {
    let minHeight: Int // 최소 키 제한
    let minAge: Int // 최소 나이 제한
    let maxParticipants: Int // 최대 참가 인원
    
    
    init(dto: ActivityRestrictionsDTO) {
        self.minHeight = dto.minHeight
        self.minAge = dto.minAge
        self.maxParticipants = dto.maxParticipants
    }
    
  
    
}

/// 액티비티  예약 아이템 정보
struct ActivityReservationItemEntity {
    let itemName: String // 예약 아이템 이름(날짜??)
    let times: ActivityReservationTimeEntity // 해당 아이템의 시간대별 예약 정보
    
    init(dto: ActivityReservationItemDTO) {
        self.itemName = dto.itemName
        self.times = ActivityReservationTimeEntity(dto: dto.times)
    }
    
}

/// 액티비티 시간대별 예약 정보
struct ActivityReservationTimeEntity {
    let time: String // 예약 시간
    let isReserved: Bool // 예약 여부
    
    init(dto: ActivityReservationTimeDTO) {
        self.time = dto.time
        self.isReserved = dto.isReserved
    }
    
}
