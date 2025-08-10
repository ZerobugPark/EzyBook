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
    let storage = KeyChainTokenStorage()
    
    private let tokenNetworkService: DefaultNetworkService // 토큰 전용 네트워크 서비스
    
    private let interceptor: TokenInterceptor
    private let networkService: DefaultNetworkService
    private let imageLoader: DefaultImageLoader
    
    private let tokenService: DefaultTokenService
    private let imageCache: ImageCache
    
    
    // MARK: Data
    let cacheManager: CacheManageable

    
    // MARK: - DIContainer Factory
    let commonDICotainer: CommonDIContainer
    
    let loginDIContainer: LoginDIContainer
    let homeDIContainer: HomeDIContainer
    let communityDIContainer: CommunityDIContainer
    let chatDIContainer: ChatDIContainer
    let profileDIContainer: ProfileDIContainer
                                                                    

    
    
    init() {
        tokenNetworkService = DefaultNetworkService(decodingService: decoder, interceptor: nil)
        /// 어차피 액세스 토큰 갱신이기 때문에, 내부에처  헤더값이랑 같이 보내주면 됨 (즉, 이 때는 인터셉터를 쓸 필요가 없음)
        tokenService = DefaultTokenService(storage: storage, networkService: tokenNetworkService)
        interceptor = TokenInterceptor(tokenService: tokenService)
        networkService = DefaultNetworkService(decodingService: decoder, interceptor: interceptor)
        
        
        imageCache = ImageCache()
        imageLoader = DefaultImageLoader(tokenService: tokenService, interceptor: interceptor)
        
        
        commonDICotainer = CommonDIContainer(
            imageLoader: imageLoader,
            imageCache: imageCache,
            networkService: networkService
        )
        
        loginDIContainer = LoginDIContainer(
            networkService: networkService,
            tokenService: tokenService
        )
        
        homeDIContainer = HomeDIContainer(
            networkService: networkService,
            commonDIContainer: commonDICotainer,
            videoLoader: VideoLoaderDelegate(
                tokenService: tokenService,
                interceptor: interceptor
            )
        )
        
        
        communityDIContainer = CommunityDIContainer(
            networkService: networkService,
            commonDIContainer: commonDICotainer
        )
        
        chatDIContainer = ChatDIContainer(
            networkService: networkService,
            commonDIContainer: commonDICotainer,
            storage: storage
        )
        
        profileDIContainer = ProfileDIContainer(
            networkService: networkService,
            commonDIContainer: commonDICotainer,
            communityDIContainer: communityDIContainer
        )
        
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

