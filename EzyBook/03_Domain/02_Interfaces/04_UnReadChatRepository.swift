//
//  02_UnReadChatRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/16/25.
//

import Foundation

protocol UnReadChatRepository: Repository where T == UnReadChatTable  {
    func increment(roomID: String)
    func reset(roomID: String)
    func total(for roomID: String) -> Int
}
