//
//  DetailView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/2/25.
//

import SwiftUI

struct DetailView: View {
    
    @Environment(\.displayScale) var scale
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: DetailViewModel
    @ObservedObject  var coordinator: HomeCoordinator

    private(set) var activityID: String

    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .onAppear {
            viewModel.action(.updateScale(scale: scale))
            viewModel.action(.onAppearRequested(id: activityID))
        }
        
    }
}

#Preview {
    
}
