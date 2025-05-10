//
//  ContentView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            if let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String {
                Text(apiKey)
            }
            
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
