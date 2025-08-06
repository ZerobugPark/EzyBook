//
//  ChatBundle.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation

struct ChatListUseCases {
    
    let sendMessages: SendMessageUseCase
    let saveRealmMessages: SaveChatMessageUseCase
    let fetchRealmLatestMessage: FetchLatestChatMessageUseCase
    let fetchRealmMessageList: FetchChatMessageListUseCase
    let fetchRemoteMessage:   FetchRemoteChatMessagesUseCase
    let uploadImage: ChatImageUploadUseCase
}


