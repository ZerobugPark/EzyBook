//
//  FilePicker.swift
//  EzyBook
//
//  Created by youngkyun park on 8/7/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct FilePickerSheetView: View {
    @Binding var isPresented: Bool
    @Binding var selectedURL: URL?
    
    var body: some View {
        EmptyView()
            .onAppear { isPresented = true }
       
    }
}
