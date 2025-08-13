//
//  CommonDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import Foundation


final class CommonDIContainer {

    private let networkService: DefaultNetworkService
    
    
    init(networkService: DefaultNetworkService) {
        self.networkService = networkService
    }
}


// MARK: Shared Feature Service (공통 모듈)
extension CommonDIContainer {
    
    func makeDetailFeatureService() -> DetailFeatureService {
        DefaultDetailFeatureService(
            chatRoom: makeChatRoomService(),
            favorite: makeFavoriteService(),
            location: makeLocationSerview()
        )
    }

    /// 내 프로필 조회
    func makeProfilLookupUseCase() -> ProfileLookUpUseCase {
        DefaultProfileLookUpUseCase(repo: makeProfileRepository())
    }
    

    /// 상대방 프로필 조회
    func makeProfileSearchUseCase() -> ProfileSearchUseCase {
        DefaultProfileSearchUseCase(repo: makeProfileRepository())
    }
    
    
    /// 액티비티 좋아요
    func makeActivityKeepCommandUseCase() -> ActivityKeepCommandUseCase {
        DefaultActivityKeepCommandUseCase(repo: makeKeepStatusRepository())
    }
    
    /// 포스트 좋아요
    func makePostLikeUseCase() -> PostLikeUseCase {
        DefaultPostLikeUseCase(repo: makeKeepStatusRepository())
    }
  
    
    // MARK: 서비스 구현체 생성
    private func makeChatRoomService() -> ChatRoomServiceProtocol {
        ChatRoomService(createChatRoomUseCase: makeCreateChatRoomUseCase())
    }
    
    private func makeFavoriteService() -> FavoriteServiceProtocol {
        FavoriteService(
            activityKeepUseCase: makeActivityKeepCommandUseCase(),
            activityKeppListUseCase: makeActivityKeepListUseCase(),
            postKeepUseCase: makePostLikeUseCase(),
            postLikeListUseCase: makePostLikeListUseCase(),
            myPostUseCase: makeMyPostUseCase()
        )
    }
    
    private func makeLocationSerview() -> LocationServiceProtocol {
        LocationService()
    }
}

// MARK: Use Cases (내부용)
extension CommonDIContainer {
    

    
    /// 채팅방 생성
    private func makeCreateChatRoomUseCase() -> CreateChatRoomUseCase {
        DefaultCreateChatRoomUseCase(repo: makeChatRoomRepository())
    }
    
    
    private func makeActivityKeepListUseCase() -> ActivityKeepListUseCase {
        DefaultActivityKeepListUseCase(repo: makeKeepStatusRepository())
    }
    
    private func makePostLikeListUseCase() -> PostLikeListUseCase {
        DefaultPostLikeListUseCase(repo: makeKeepStatusRepository())
    }
    
    private func makeMyPostUseCase() -> MyPostUseCase {
        DefaultMyPostUseCase(repo: makeKeepStatusRepository())
    }
    
}
// MARK: Data (내부용)
extension CommonDIContainer {
        
    private func makeKeepStatusRepository() -> DefaultKeepStatusRepository {
        DefaultKeepStatusRepository(
            networkService: networkService
        )
    }
    
}

// MARK: Data
extension CommonDIContainer {
    
    func makeProfileRepository() -> DefaultProfileRepository {
        DefaultProfileRepository(
            networkService: networkService
        )
    }
    
    /// 이미지 업로드
    func makeUploadRepository() -> DefaultUploadFileRepository {
        DefaultUploadFileRepository(
            networkService: networkService
        )
    }
    
    
    /// 주문 관리
    func makeOrderRepository() -> DefaultOrderRepository {
        DefaultOrderRepository(
            networkService: networkService
        )
    }
    
    /// 리뷰 관리
    func makeReviewRepository() -> DefaultReviewRepository {
        DefaultReviewRepository(networkService: networkService)
    }
    
    func makeChatRepository() -> DefaultChatRepository {
        DefaultChatRepository(networkService: networkService)
    }
    
    
    /// 채팅 방 관련
    func makeChatRoomRepository() -> DefaultChatRepository {
        DefaultChatRepository(networkService: networkService)
    }
  
}

    
