//
//  PDFViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/7/25.
//

import SwiftUI
import Combine

final class PDFViewModel: ViewModelType {

    var input = Input()
    @Published var output = Output()

    
    var cancellables = Set<AnyCancellable>()
    
    private let fileLoad: DefaultFileLoadUseCase
    private let path: String
    
    init(fileLoad: DefaultFileLoadUseCase, path: String) {
        self.fileLoad = fileLoad
        self.path = path

        transform()
        loadInitialPDF()
    }
    
    
 
}

// MARK: Input/Output
extension PDFViewModel {
    
    struct Input {
    }
    
    struct Output {
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var data: Data?
        
    }
    

    func transform() {  }
    
    
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedMessage = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedMessage = DisplayMessage.error(code: -1, msg: error.localizedDescription)
        }
    }
    
}

// MARK:
extension PDFViewModel {
    
    private func loadInitialPDF() {
        Task {
            await performLoadPDF()
        }
    }
    
    private func performLoadPDF() async {
        do {
            let data = try await fileLoad.execute(path: path)
            
            await MainActor.run {
                output.data = data
            }
            
        } catch {
            await handleError(error)
        }
    }

}


// MARK: Alert 처리
extension PDFViewModel: AnyObjectWithCommonUI {
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
}

