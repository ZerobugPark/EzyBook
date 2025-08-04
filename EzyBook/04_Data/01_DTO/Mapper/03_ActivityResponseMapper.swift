//
//  ActivityResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation


extension ActivitySummaryListResponseDTO {
    func toEntity() -> ActivitySummaryListEntity {
        ActivitySummaryListEntity(dto: self)
    }
    
}

extension ActivityDetailResponseDTO {
    func toEntity() -> ActivityDetailEntity {
        ActivityDetailEntity(dto: self)
    }
}

extension ActivityKeepResponseDTO {
    func toEntity() -> ActivityKeepEntity {
        ActivityKeepEntity(keepStatus: self.keepStatus)
    }
}

extension ActivityListResponseDTO {
    func toEntity() -> [ActivitySummaryEntity] {
        self.data.map { ActivitySummaryEntity(dto: $0) }
        
    }
}

