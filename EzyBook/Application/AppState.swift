//
//  AppState.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoding = false
}
