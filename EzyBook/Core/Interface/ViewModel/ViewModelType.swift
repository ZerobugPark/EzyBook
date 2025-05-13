//
//  ViewModelType.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import Combine
import Foundation

protocol ViewModelType: AnyObject, ObservableObject {
    associatedtype Input
    associatedtype Output
    
    var cancellables: Set<AnyCancellable> { get set } //disposeBag
    
    var input: Input { get set }
    var output: Output { get set }
    
    func transform()
}
