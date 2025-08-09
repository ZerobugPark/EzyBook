//
//  ActivityPostRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import UIKit
import Alamofire



// MARK:  Get
enum ActivityPostRequest {
    
    enum Get: GetRouter {
        
       
        case postLookup(query: ActivityPostLookUpQuery) // 위치 기반 게시글 조회
        case postSearch(query: String) // 게시글 검색 검색
        case detailPost(postID: String) // 상세조회
        case writtenPost(userID: String, dto: MyActivityQuery) //내가 작성한 게시글
        case likedPosts(dto: MyActivityQuery) // 내가 킵한 액티비티 리스트
        

        //case deletePost(postID: String) // 게시글 삭제 나중에 만들자
        
        //            case .deletePost(let postID):
        //                ActivityPostEndPoint.deletePost(postID: postID).requestURL
        
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .postLookup:
                ActivityPostEndPoint.postLookup.requestURL
            case .postSearch:
                ActivityPostEndPoint.postSearch.requestURL
            case .detailPost(let postID):
                ActivityPostEndPoint.detailPost(postID: postID).requestURL
            case .writtenPost(let userID, _):
                ActivityPostEndPoint.writtenPost(userID: userID).requestURL
            case .likedPosts:
                ActivityPostEndPoint.likedPosts.requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
        
        var parameters: Parameters? {
            switch self {
            case .postLookup(let param):
                /// 파라미터 타입으로 할 경우 옵셔널에 대한 대응이 불가능해서
                /// return시 업 캐스팅 처리
                /// [String: String]은 [String: Any]의 하위 타입
                let result: [String: Any?] = [
                     "country": param.country,
                     "category": param.category,
                     "longitude": param.longitude,
                     "latitude": param.latitude,
                     "maxDistance": param.maxDistance ,
                     "limit": param.limit,
                     "next": param.next,
                     "order_by": param.orderBy
                     
                 ]
                
                let filtered = result.compactMapValues { $0 } // 옵셔널 제거
                return filtered.isEmpty ? nil : filtered as Parameters // 업캐스팅
                
            case .postSearch(let param):
                return ["title": param]
            case .detailPost(let id):
                return ["post_id": id]
            case .writtenPost(_, let param), .likedPosts(let param):
                let result: [String: Any?] = [
                     "country": param.country,
                     "category": param.category,
                     "limit": param.limit,
                     "next": param.next,
                 ]
                
                let filtered = result.compactMapValues { $0 } // 옵셔널 제거
                return filtered.isEmpty ? nil : filtered as Parameters // 업캐스팅
            }
        }
    }
}


// MARK:  Post
extension ActivityPostRequest {
    
    enum Post: PostRouter {
        case writePost(body: ActivityPostRequestDTO) //게시글 작성
        case postKeep(postID: String, body: ActivityPostLikeRequestDTO) //게시글 킵/킵취소
     
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .writePost:
                ActivityPostEndPoint.writePost.requestURL
            case .postKeep(let postID, _):
                ActivityPostEndPoint.postKeep(postID: postID).requestURL
            
            }
        }
        
  
        var requestBody: Encodable? {
            switch self {
            case .writePost(let body):
                return body
            case .postKeep(_, let body):
                return body
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
    }
    
    
}

// MARK: Put
extension ActivityPostRequest {
    
    enum Put: PutRouter {
        
        case modifyPost(postID: String, body: ActivityPostModifyRequestDTO) // 게시글 수정
        
        var requiresAuth: Bool {
            return true
        }
        
        var endpoint: URL? {
            switch self {
            case .modifyPost(let postID, _):
                ActivityPostEndPoint.modifyPost(postID: postID).requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case .modifyPost(_, let body):
                return body
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }

    }
    
}


// MARK: MultiPart
extension ActivityPostRequest {
    
    enum Multipart: MultipartRouter {
   
        
        case postImages(images: [UIImage]) // 포스트 파일 업로드
        case postVideos(videos: [Data])
        
        var requiresAuth: Bool {
            return true
        }
        
        var endpoint: URL? {
            switch self {
            case .postImages, .postVideos:
                ActivityPostEndPoint.postFiles.requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }
        
        // MARK: - Cached Compressed Data
        var compressedImages: [Data] {
            switch self {
            case .postImages(let images):
                return images.compactMap { $0.compressedJPEGData(maxSizeInBytes: 1_000_000) }
            default:
                return []
            }
        }
        

        // MARK: - 비어있는지 확인
        var isEffectivelyEmpty: Bool {
            switch self {
            case .postImages:
                return compressedImages.isEmpty
            case .postVideos(let videos):
                return videos.isEmpty
            }
        }
        
        
    // MARK: - Multipart Form 구성
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .postImages:
            return { form in
                for (index, data) in compressedImages.enumerated() {
                    form.append(
                        data,
                        withName: "files",
                        fileName: "image_\(index).jpg",
                        mimeType: "image/jpeg"
                    )
                }
            }

        case .postVideos(let vidoes):
            return { form in
                for (index, data) in vidoes.enumerated() {
                    form.append(
                        data,
                        withName: "files",
                        fileName: "video_\(index).mp4",
                        mimeType: "video/mp4"
                    )
                }
            }
        }
    }
    }
}
