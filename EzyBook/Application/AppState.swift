//
//  AppState.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoding: Bool = false
}
