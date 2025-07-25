//
//  ProfileBundle.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import Foundation

struct ProfileUseCases {
    let profileLookUp: ProfileLookUpUseCase
    let profileSearchUser: ProfileSearchUseCase
    let profileUploadImage: ProfileUploadImageUseCase
    let profileModify: ProfileModifyUseCase
}
