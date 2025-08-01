//
//  HomeViewEnum.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import SwiftUI

enum Flag: String, CaseIterable, Identifiable {
    case all = ""
    case korea = "대한민국"
    case japan = "일본"
    case taiwan = "대만"
    case thailand = "태국"
    case philippines = "필리핀"
    case australia = "호주"
    case argentina = "아르헨티나"
    
    var id: String { self.rawValue }
    
    var image: Image {
        switch self {
        case .all:
                .init(.flagEarth)
        case .korea:
                .init(.flagKorea)
        case .japan:
                .init(.flagJapan)
        case .taiwan:
                .init(.flagTaiwan)
        case .thailand:
                .init(.flagThailand)
        case .philippines:
                .init(.flagPhilippines)
        case .australia:
                .init(.flagAustralia)
        case .argentina:
                .init(.flagArgentina)
        }
    }
    
    var requestValue: String? {
        self == .all ? nil : self.rawValue
    }
}

enum Filter: String, CaseIterable, Identifiable {
    case all = "전체"
    case sightseeing = "관광"
    case tour = "투어"
    case package = "패키지"
    case exciting = "익사이팅"
    case experience = "체험"
    
    var id: String { self.rawValue }
    
    var requestValue: String? {
        self == .all ? nil : self.rawValue
    }
    
}
