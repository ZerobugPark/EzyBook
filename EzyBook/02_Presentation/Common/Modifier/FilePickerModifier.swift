//
//  FilePickerModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 8/7/25.
//

import SwiftUI
//import UniformTypeIdentifiers

struct FilePickerModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedURL: URL?
    let onSelected: () -> Void
    
    func body(content: Content) -> some View {
        content.fileImporter(
            isPresented: $isPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                selectedURL = urls.first
                onSelected()
            case .failure:
                selectedURL = nil
            }
        }
    }
}
 
extension View {
    func filePicker(isPresented: Binding<Bool>, selectedURL: Binding<URL?>, onSelect: @escaping () -> Void) -> some View {
        self.modifier(FilePickerModifier(isPresented: isPresented, selectedURL: selectedURL, onSelected: onSelect))
    }
}
 
  
