//
//  ChatListView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

struct ChatListView: View {
    
    @StateObject var viewModel: ChatListViewModel
    @ObservedObject var coordinator: ChatCoordinator
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                ForEach(viewModel.output.chatRoomList, id: \.id) { item in
                    ChatListCardView(list: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            //coordinator.push(.chatRoomView(roomID: item.roomID, opponentNick: item.participants[item.opponentIndex ?? 0].nick))
                        }
                        
                        
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TitleTextView(title: "채팅")
            }
            
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
    }
        
}


/// 채팅 목록
extension ChatListView {
    
    struct ChatListCardView: View {
        
        let list: LastMessageSummary
        
        
        var body: some View {
            
            
            HStack(alignment: .top, spacing: 10) {
                ProfileImageView(path: list.opponentInfo.profileImageURL, size: 44)
                
                VStack(alignment: .leading, spacing: 5) {
                    /// 채팅하는 사람
                    Text(list.opponentInfo.nick)
                        .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    /// 마지막 채팅 내역
                    Text(list.content)
                        .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
                Text(list.formattedDate)
                    .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
            }
            .padding()
            
        }
    }
    

    

}

