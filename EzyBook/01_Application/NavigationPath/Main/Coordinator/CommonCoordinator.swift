//
//  CommonCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 8/11/25.
//

import SwiftUI


protocol PostsRouting: AnyObject {
    func pop()
}

protocol  ActivitySelectableRouting: AnyObject {
    func presentActivityPicker(onSelected: @escaping (OrderList) -> Void) -> AnyView
}

final class AnyPostsRouter: ObservableObject, PostsRouting {
    
    private let _pop: () -> Void
    private let activitySelectable: ActivitySelectableRouting?
    var canPresentActivityPicker: Bool { activitySelectable != nil }
    
    init<R: PostsRouting>(_ router: R) {
        self._pop = router.pop
        self.activitySelectable = router as? ActivitySelectableRouting
    }
    
    func pop() { _pop() }
    
    func presentActivityPicker(onSelected: @escaping (OrderList) -> Void) -> AnyView {
        guard let activitySelectable else {
            assertionFailure("presentActivityPicker called but router doesn't support ActivitySelectableRouting")
            return AnyView(EmptyView())
        }
        return activitySelectable.presentActivityPicker(onSelected: onSelected)
    }
}



// MARK: - Router Adapters
/// Community tab adapter — provides the activity picker via closure
final class CommunityCoordinatorRouter: PostsRouting, ActivitySelectableRouting {

    
    private let coordinator: CommunityCoordinator
    init(coordinator: CommunityCoordinator) { self.coordinator = coordinator }
    func pop() { coordinator.pop() }
    
    
    func presentActivityPicker(onSelected: @escaping (OrderList) -> Void) -> AnyView {
        AnyView(coordinator.makeMyActivityView(onConfirm: onSelected))  // AnyView - 불투명 타입 지우기
    }
}

/// Profile tab adapter —no activity picker here
final class ProfileCoordinatorRouter: PostsRouting {

    private let coordinator: ProfileCoordinator
    init(coordinator: ProfileCoordinator) { self.coordinator = coordinator }
    func pop() { coordinator.pop() }
}
