//
//  04_ChatResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation


extension ChatRoomResponseDTO {
    func toEntity() -> ChatRoomEntity {
        ChatRoomEntity(dto: self)
    }
}
