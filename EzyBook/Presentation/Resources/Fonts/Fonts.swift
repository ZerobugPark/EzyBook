//
//  Fonts.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import Foundation

protocol FontStyle {
    var fontName: String { get }
    var size: CGFloat { get }
}


/// 페이퍼 로지
enum PaperlogyFontStyle {
    case title, body, caption
}

extension PaperlogyFontStyle: FontStyle {
    
    var fontName: String {
        switch self {
        case .title, .body, .caption:
            return "Paperlogy-9Black"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .title:
            return 26
        case .body:
            return 22
        case .caption:
            return 14
        }
    }
    
}

/// 프리텐다드
enum PretendardFontStyle {
    case title1
    case body1, body2, body3
    case caption1, caption2, caption3
}

extension PretendardFontStyle: FontStyle {
    
    var fontName: String {
        switch self {
        case .title1:
            return "Pretendard-Bold"
        case .body1, .body2, .body3:
            return "Pretendard-Medium"
        case .caption1, .caption2, .caption3:
            return "Pretendard-Regular"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .title1:
            return 20
        case .body1:
            return 16
        case .body2:
            return 14
        case .body3:
            return 13
        case .caption1:
            return 12
        case .caption2:
            return 10
        case .caption3:
            return 8
        }
    }
    
    
}
