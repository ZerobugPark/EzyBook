//
//  AppDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

final class AppDIContainer {
    func makeDIContainer() -> DIContainer {
        let networkManger = NetworkService()
        let decoder = ResponseDecoder()
        
        return DIContainer(networkManger: networkManger, decodingManger: decoder)
    }
}
