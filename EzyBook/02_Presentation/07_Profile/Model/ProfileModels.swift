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
    var nick: String
    var profileImage: UIImage?
    var phoneNum: String
    var introduction: String
    
    init (from detail: ProfileLookUpEntity, profileImage: UIImage?) {
        self.userID = detail.userID
        self.email = detail.email
        self.nick = detail.nick
        self.profileImage = profileImage
        self.phoneNum = detail.phoneNum
        self.introduction = detail.introduction.isEmpty ? "소개를 작성해주세요" : detail.introduction

    }
    
    init(from profile: UserInfoResponseEntity, profileImage: UIImage?) {
        self.userID = profile.userID
        self.email = ""
        self.nick = profile.nick
        self.profileImage = profileImage
        self.phoneNum = ""
        self.introduction = profile.introduction ?? ""
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
        profileImage: nil
        
    )
    
    
}

