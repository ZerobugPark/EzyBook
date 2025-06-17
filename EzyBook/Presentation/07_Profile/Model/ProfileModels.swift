//
//  ProfileModels.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct ProfileLookUpModel {
    
    let userID: String
    let email: String
    let nick: String
    var profileImage: UIImage?
    let phoneNum: String
    let introduction: String
    
    // 금액이 다를 경우 어떻게 비교를 해줄까?
    
    init (from detail: ProfileLookUpEntity, profile: UIImage?) {
        self.userID = detail.userID
        self.email = detail.email
        self.nick = detail.nick
        self.profileImage = profile
        self.phoneNum = detail.phoneNum
        self.introduction = detail.introduction.isEmpty ? "소개를 작성해주세요" : detail.introduction

    }
    
}

// MARK: Skeleton

extension ProfileLookUpModel {
    
    static let skeleton = ProfileLookUpModel(
        from: ProfileLookUpEntity(
            dto: ProfileLookUpResponseDTO(
                userID: "loading-id",
                email: "loading@email.com",
                nick: "로딩 중...",
                profileImage: "", // 기본 이미지를 보여주게 할 수 있음
                phoneNum: "010-0000-0000",
                introduction: "사용자 소개를 불러오는 중입니다..."
            )
        ),
        profile: nil
        
    )
    
    
}

