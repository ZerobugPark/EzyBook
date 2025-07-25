//
//  CommunityView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct CommunityView: View {
    
    @State private var selectedPost = false
    
    @ObservedObject var coordinator: CommunityCoordinator
    
    var body: some View {
        ZStack {
            makePostButton()
        }
        .sheet(isPresented: $selectedPost) {
            coordinator.makePostsView()
        }
    }
    
     
    
}


// MARK: Post View
extension CommunityView {

    private func makePostButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    selectedPost = true
                }) {
                    Label {
                        Text("글쓰기")
                            .appFont(PaperlogyFontStyle.caption, textColor: .grayScale0)
                    } icon: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.grayScale0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blackSeafoam))
                }
                .shadow(radius: 5)
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
    }
}
