//
//  PDFViewr.swift
//  EzyBook
//
//  Created by youngkyun park on 8/7/25.
//

import SwiftUI
import PDFKit


struct PDFFullScreenView: View {
    let path: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: AppDIContainer
    
    var body: some View {
        PDFFullScreenViewImpl(path: path, container: container)
    }
}

fileprivate struct PDFFullScreenViewImpl: View {

    @StateObject private var viewModel: PDFViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(path: String, container: AppDIContainer) {
        _viewModel = StateObject(
            wrappedValue: PDFViewModel(
                fileLoad: container.chatDIContainer.makeFileLoadUseCase(), path: path)
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                if let data = viewModel.output.data {
                    PDFKitView(data: data)
                } else {
                    ProgressView()
                }
            }
            .withCommonUIHandling(viewModel) { _, _ in
                dismiss()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("완료")
                            .appFont(PaperlogyFontStyle.caption, textColor: .blackSeafoam)
                    }
                }
            }
        }
    }
    
}

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        /// 페이지 단위
        pdfView.displayMode = .singlePage
        pdfView.usePageViewController(true, withViewOptions: nil)
        /// 하나의 페이지를 여러개 보여줌
        //pdfView.displayMode = .singlePageContinuous
        /// 방향 설정 (하나의 페이지에 여러개 보여줄 때 필요)
        //pdfView.displayDirection = .vertical
        /// 문서 설정
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }
    func updateUIView(_ uiView: PDFView, context: Context) { }
}



