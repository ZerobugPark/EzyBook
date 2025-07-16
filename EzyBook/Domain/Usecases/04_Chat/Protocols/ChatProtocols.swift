//
//  ChatProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/16/25.
//

import Foundation

protocol SendMessageUseCase {
    func execute(roomId: String, content: String, files: [String]?) async throws -> ChatEntity
}
