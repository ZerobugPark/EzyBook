//
//  CommnetModifyView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import SwiftUI

struct CommnetModifyView: View {
    @State private var text: String
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    let onSave: (String) -> Void
  
    
    init(initialText: String, onSave: @escaping (String) -> Void) {
        self._text = State(initialValue: initialText)
        self.onSave = onSave
    }
    

    var body: some View {
        VStack(spacing: 0) {
            CommonNavigationBar(
                title: "댓글수정 ", leadingAction: {
                    dismiss()
                }) {
                    if !text.isEmpty {
                        onSave(text)
                        dismiss()
                    } else {
                        showAlert = true
                    }
                }

            TextEditor(text: $text)
                .focused($isFocused)
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding()

            Spacer()
        }
        .background(
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }
        )
        .alert("내용을 확인해주세요.", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        }
    }

    
}
