//
//  SearchModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import SwiftUI

struct SearchModifier: ViewModifier {
    @Binding var query: String
    @Binding var isSearching: Bool

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .searchable(text: $query, isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always))
        } else {
            content
                .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}

extension View {
    
    func searchModify(_ query: Binding<String>, _ isSearching: Binding<Bool>) -> some View {
        modifier(SearchModifier(query: query, isSearching: isSearching))
    }
}
