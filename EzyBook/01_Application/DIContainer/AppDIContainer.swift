//
//  AppDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

final class AppDIContainer: ObservableObject {
    
    // MARK: - Infrastructure
    private let decoder = ResponseDecoder()
    
    private let tokenNetworkService: DefaultNetworkService // 토큰 전용 네트워크 서비스
    
    private let interceptor: TokenInterceptor
    private let networkService: DefaultNetworkService
    private let imageLoader: DefaultImageLoader
    
    private let tokenService: DefaultTokenService
    private let imageCache: ImageCache
    
    
    // MARK: Data
    let cacheManager: CacheManageable
    
    // MARK: Infra
    let videoLoaderDelegate: VideoLoaderDelegate

    
    // MARK: - DIContainer
    
    private let loginDIContainer: LoginDIContainer
    
    private let commonDICotainer: CommonDIContainer
    private let mediaDIConatiner: MediaDIContainer
    
    private let homeDIContainer: HomeDIContainer
    private let chatDIContainer: ChatDIContainer
    private let communityDIContainer: CommunityDIContainer
    private let profileDIContainer: ProfileDIContainer
    
    
    //MARK: Factory
    let loginFactory: LoginFactory
    let mediaFactory: MediaFactory
    
    let homeFactory: HomeFactory
    let communityFactory: CommunityFactory
    let chatFactory: ChatFactory
    let profileFactory: ProfileFactory
    
    
    init() {
        tokenNetworkService = DefaultNetworkService(decodingService: decoder, interceptor: nil)
        /// 어차피 액세스 토큰 갱신이기 때문에, 내부에처  헤더값이랑 같이 보내주면 됨 (즉, 이 때는 인터셉터를 쓸 필요가 없음)
        tokenService = DefaultTokenService(storage: KeyChainTokenStorage.shared, networkService: tokenNetworkService)
        interceptor = TokenInterceptor(tokenService: tokenService)
        networkService = DefaultNetworkService(decodingService: decoder, interceptor: interceptor)
        
        
        imageCache = ImageCache()
        imageLoader = DefaultImageLoader(tokenService: tokenService, interceptor: interceptor)
        videoLoaderDelegate = VideoLoaderDelegate(tokenService: tokenService, interceptor: interceptor)
        
        
        /// 공통 사용
        mediaDIConatiner = MediaDIContainer(
            imageLoader: imageLoader,
            videoLoader: videoLoaderDelegate,
            imageCache: imageCache
        )
        mediaFactory = mediaDIConatiner.makeFactory()
        
        commonDICotainer = CommonDIContainer(
            networkService: networkService
        )
        
        
        /// 로그인
        loginDIContainer = LoginDIContainer(
            networkService: networkService,
            tokenService: tokenService
        )
        
        loginFactory = loginDIContainer.makeFactory()
        
        /// 채팅 공통 및 채팅 목록
        chatDIContainer = ChatDIContainer(
            networkService: networkService,
            commonDIContainer: commonDICotainer,
            storage: KeyChainTokenStorage.shared
        )
        
        chatFactory = chatDIContainer.makeFactory()
        
        /// 홈 화면
        homeDIContainer = HomeDIContainer(
            networkService: networkService,
            commonDIContainer: commonDICotainer,
            mediaFactory: mediaFactory,
            chatFactory: chatFactory
        )
        
        homeFactory = homeDIContainer.makeFactory()
        
        
        communityDIContainer = CommunityDIContainer(
            networkService: networkService,
            commonDIContainer: commonDICotainer,
            mediaFactory: mediaFactory
        )
        
        communityFactory = communityDIContainer.makeFactory()
        
  
        profileDIContainer = ProfileDIContainer(
            networkService: networkService,
            commonDIContainer: commonDICotainer,
            communityFactory: communityFactory
        )
        
        profileFactory = profileDIContainer.makeFactory()
        
        cacheManager = CacheManager(imageCache: imageCache)
        
    }
    


}


extension AppDIContainer {
    // MARK: 앱 시작 시 세션 초기화 (토큰 갱신 + 유저 정보 최신화)
    func initializeAppSession() async throws {

        // 1) 토큰 갱신
        try await refreshAccessTokenIfNeeded()

        // 2) 최신 유저 정보 가져오기 (없을 경우, 기존 User 정보)
        await initializeUserSession()

    }

    // MARK: 토큰 갱신 추가
    private func refreshAccessTokenIfNeeded() async throws {
        try await tokenService.refreshToken()
    }

    // MARK: 서버에서 최신 유저 정보 업데이트
    private func initializeUserSession() async {
        do {
            let latestUser = try await commonDICotainer.makeProfilLookupUseCase().execute()

            let userInfo = UserEntity(
                userID: latestUser.userID,
                email: latestUser.email,
                nick: latestUser.nick
            )

            UserSession.shared.update(userInfo)

        } catch {
            print("최신 유저 정보 가져오기 실패: \(error)")
        }
    }
}

