//
//  SocialLoginViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import SwiftUI
import Combine


final class SocialLoginViewModel: ViewModelType {
    
    var useCase: DefaultSocialLoginUseCase
    
    var input = Input()
    @Published var output = Output()
        
    var cancellables = Set<AnyCancellable>()
    
    init(useCase: DefaultSocialLoginUseCase) {
        self.useCase = useCase
        transform()
    }
}

// MARK: Input/Output
extension SocialLoginViewModel {
    
    struct Input {
     
    }
    
    struct Output {
     

    }
    
    func transform() { }
    
    private func test() {
        useCase.kakaoLogin { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
  
}

// MARK: Action
extension SocialLoginViewModel {
    
    enum Action {
        case logunButtonTapped
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .logunButtonTapped:
            test()
        case .resetError:
          break
        }
    }
}



