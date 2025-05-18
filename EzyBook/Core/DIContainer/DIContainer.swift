//
//  DIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

///
/// 공통 모듈
/// 네트워크 서비스?, 저장소 패턴, 또 뭐가 있을끼?

final class DIContainer: ObservableObject {

    private let networkManger: NetworkService
    private let decodingManger: ResponseDecoder
    
    init(networkManger: NetworkService, decodingManger: ResponseDecoder) {
        self.networkManger = networkManger
        self.decodingManger = decodingManger
    }
    
    private func makeNetworkRepository() -> NetworkRepository {
        return NetworkRepository(networkManger: networkManger, decodingManager: decodingManger)
    }
    
}

// MARK: Make ViewModel
extension DIContainer {
    func makeAccountViewModel() -> CreateAccountViewModel {
        return CreateAccountViewModel(newtworkRepository: self.makeNetworkRepository())
    }
    
    func makeEmailLoginViewModel() -> EmailLoginViewModel {
        return EmailLoginViewModel(newtworkRepository: self.makeNetworkRepository())
    }
    
}
