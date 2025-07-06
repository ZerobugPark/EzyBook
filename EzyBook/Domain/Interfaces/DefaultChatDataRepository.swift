//
//  DefaultChatDataRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/3/25.
//

import Foundation

protocol DefaultChatDataRepository: Repository where T == ChatMessageObject {
    func save(chatList: [ChatMessageEntity])
}
