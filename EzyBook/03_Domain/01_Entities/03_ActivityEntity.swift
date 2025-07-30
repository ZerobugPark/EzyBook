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
    var thumbnailPaths: [String] // 썸네일 이미지 경로
    let geolocation: ActivityGeolocationEntity // 위치
    let startDate: String // 액비비티 운영 기간(시작)
    let endDate: String? // 액비비티 운영 기간(종료)
    let price: ActivityPriceEntity // 가격
    let tags: [String] // 태그 (ex. 오픈할인)
    let pointReward: Int // 액티비티 포인트 리워드
    let restrictions: ActivityRestrictionsEntity // 제한 사항
    let description: String //설명
    let isAdvertisement: Bool //광고 여부
    var isKeep: Bool // 현재 유저의 킵 여부
    let keepCount: Int // 이 액티비티의 총 킵 수
    let totalOrderCount: Int // 총 주문 예약
    let schedule: [ActivityScheduleItemEntity] // 일정 정보
    let reservationList: [ActivityReservationItemEntity] // 예약 리스트
    let creator: ActivityCreatorEntity // 게시자
    let createdAt: String?
    let updatedAt: String?
    
    var discountRate: String {
        
        let discountRate = 100 - ceil(Double(price.final) / Double(price.original) * 100)
        let formatted = discountRate.formattedPercentage()
        return "\(formatted)%"
        
    }
    
    init(dto: ActivityDetailResponseDTO) {
        self.activityID = dto.activityID
        self.title = dto.title ?? ""
        self.country = dto.country ?? ""
        self.category = dto.category ?? ""
        self.thumbnailPaths = dto.thumbnails
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
        self.schedule = dto.schedule.map {ActivityScheduleItemEntity(dto: $0) }
        self.reservationList = dto.reservationList.map { ActivityReservationItemEntity(dto: $0)}
        self.creator = ActivityCreatorEntity(dto: dto.creator)
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
    
}

/// 자기 자신을 복사한 후, 값을 변경  후 리턴
/// 구조체에서는 부분 수정보다는 새로운 값을 만들어서 교체하는 방식
/// Swfit의 철학
extension ActivityDetailEntity {
    func with(thumbnails: [String]) -> ActivityDetailEntity {
        var copy = self
        copy.thumbnailPaths = thumbnails
        return copy
    }
}



/// // 액티비티 킵/ 킵 취소 작업 후 상태
struct ActivityKeepEntity {
    let keepStatus: Bool // 현재 액비비티에 대한 사용자의 킵 상태 (즉 킵을 하면 true가 리턴)
}




// MARK: 공통 Entity

/// 액티비티 위치
struct ActivityGeolocationEntity: Equatable, Hashable {
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
struct ActivityPriceEntity: Equatable, Hashable {
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
    let times: [ActivityReservationTimeEntity] // 해당 아이템의 시간대별 예약 정보
    
    var soldOut: Bool {
        let data = times.map { $0 }.filter { $0.isReserved != true }
        return data.isEmpty
    }
    
    init(dto: ActivityReservationItemDTO) {
        self.itemName = dto.itemName
        self.times = dto.times.map { ActivityReservationTimeEntity(dto: $0) }
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

struct ActivityCreatorEntity {
    let userID: String
    let nick: String
    let introduction: String?
    
    init(dto: ActivityCreatorDTO) {
        self.userID = dto.userID
        self.nick = dto.nick
        self.introduction = dto.introduction
    }
    
}


// MARK:  Mock Data
extension ActivityDetailEntity {
    
    static let skeleton = ActivityDetailEntity(
        dto: ActivityDetailResponseDTO(
            activityID: "",
            title: "로딩 중...",
            country: "",
            category: "",
            thumbnails: Array(repeating: "", count: 3), // 썸네일 개수만큼 빈 이미지
            geolocation: ActivityGeolocationDTO(longitude: 0, latitude: 0),
            startDate: "",
            endDate: "",
            price: ActivityPriceDTO(original: 0, final: 0),
            tags: [],
            pointReward: 0,
            restrictions: ActivityRestrictionsDTO(minHeight: 0, minAge: 0, maxParticipants: 0),
            description: "잠시만 기다려주세요...",
            isAdvertisement: false,
            isKeep: false,
            keepCount: 0,
            totalOrderCount: 0,
            schedule: [],
            reservationList: [],
            creator: ActivityCreatorDTO(userID: "", nick: "로딩 중", introduction: ""),
            createdAt: "",
            updatedAt: ""
        )
    )
    
    
    
    static let mock = ActivityDetailEntity(
        dto: ActivityDetailResponseDTO(
            activityID: "683ac1df0b936fc974845bf1",
            title: "환상적인 휴양 체험",
            country: "일본",
            category: "익사이팅",
            thumbnails: [
                "/data/activities/rachel-cook-mOcdke2ZQoE_1747149083412.jpg",
                "/data/activities/12834714_540_960_60fps_1747149190516.mp4",
                "/data/activities/jieun-lim-oMsXE4kIKC8_1747149006794.jpg"
            ],
            geolocation: ActivityGeolocationDTO(longitude: 139.6503, latitude: 35.6762),
            startDate: "2025-12-06",
            endDate: "2025-12-09",
            price: ActivityPriceDTO(original: 341000, final: 123000),
            tags: [],
            pointReward: 220,
            restrictions: ActivityRestrictionsDTO(minHeight: 148, minAge: 19, maxParticipants: 8),
            description: """
            스포츠의 즐거움을 만끽할 수 있는 액티비티입니다!
            초보자도 쉽게 따라할 수 있는 친절한 지도가 제공됩니다.
            건강한 몸과 마음을 만들어가는 시간이 될 것입니다.
            """,
            isAdvertisement: false,
            isKeep: true,
            keepCount: 2,
            totalOrderCount: 0,
            schedule: [
                //    ActivityScheduleItemDTO(duration: "1일차", description: "도착 및 숙소 체크인, 환영 만찬"),
                //    ActivityScheduleItemDTO(duration: "2일차", description: "자유 시간 및 출발"),
                //    ActivityScheduleItemDTO(duration: "3일차", description: "복귀")
            ],
            reservationList: [
                //                ActivityReservationItemDTO(
                //                    itemName: "2025-12-06",
                //                    times: (10...17).map { hour in
                //                        ActivityReservationTimeDTO(time: "\(hour):00", isReserved: false)
                //                    }
                //                ),
                //                ActivityReservationItemDTO(
                //                    itemName: "2025-12-07",
                //                    times: (10...17).map { hour in
                //                        ActivityReservationTimeDTO(time: "\(hour):00", isReserved: false)
                //                    }
                //                ),
                //                ActivityReservationItemDTO(
                //                    itemName: "2025-12-08",
                //                    times: (10...17).map { hour in
                //                        ActivityReservationTimeDTO(time: "\(hour):00", isReserved: true)
                //                    }
                //                ),
                //                ActivityReservationItemDTO(
                //                    itemName: "2025-12-09",
                //                    times: (10...17).map { hour in
                //                        ActivityReservationTimeDTO(time: "\(hour):00", isReserved: false)
                //                    }
                //                )
            ],
            creator: ActivityCreatorDTO(userID: "683a9ed50b936fc97483b4b3", nick: "bran", introduction: "안녕하세요!"),
            createdAt: "2025-05-31T08:46:23.687Z",
            updatedAt: "2025-05-31T08:46:23.687Z"
        )
    )
}
