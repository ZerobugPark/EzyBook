//
//  ReViewRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import SwiftUI
import Alamofire

enum ReviewRequest {
    
    enum Get: GetRouter {
        case reviewList(id: String)
        case reviewDetail(id: String, reviewID: String)
        case reviewRatingList(id: String)
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .reviewList(let id):
                return ReviewEndPoint.reviewList(id: id).requestURL
            case .reviewDetail(let id, let reviewID):
                return ReviewEndPoint.reviewDelete(id: id, reviewID: reviewID).requestURL
            case .reviewRatingList(let id):
                return ReviewEndPoint.reviewRatingList(id: id).requestURL
            }
        }
        
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
        
    }
}

// MARK: Post
extension ReviewRequest {
    
    enum Post: PostRouter {
        case writeReview(id: String, dto: ReviewWriteRequestDTO)
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .writeReview(let id, _):
                ReviewEndPoint.writeReview(id: id).requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case .writeReview(_, let request):
                return request
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
extension ReviewRequest {
    
    enum Put: PutRouter {
        case modifyReview(id: String, dto: ReviewWriteRequestDTO)
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .modifyReview(let id, _):
                ReviewEndPoint.writeReview(id: id).requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case .modifyReview(_, let request):
                return request
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
    }
}

// MARK: Delete
extension ReviewRequest {
    
    enum Delete: DeleteRouter {
        case reviewDelete(id: String, reviewID: String)
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case let .reviewDelete(id, reviewID):
                ReviewEndPoint.reviewDelete(id: id, reviewID: reviewID).requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case .reviewDelete:
                return nil
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
extension ReviewRequest {
    
    enum Multipart: MultipartRouter {
        
        case reviewFiles(id: String, image: [UIImage])
        
        var requiresAuth: Bool {
            return true
        }
        
        var endpoint: URL? {
            switch self {
            case .reviewFiles(let id, _):
                return ReviewEndPoint.reviewFiles(id: id).requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }
        
        private var compressedImages: [Data] {
            switch self {
            case .reviewFiles(_, let images):
                return images.compactMap { $0.compressedJPEGData(maxSizeInBytes: 1_000_000) }
            }
        }
        
        
        var isEffectivelyEmpty: Bool {
            switch self {
            case .reviewFiles:
                return compressedImages.isEmpty
            }
        }
        
        var multipartFormData: ((MultipartFormData) -> Void)? {
            switch self {
            case .reviewFiles:
                return { form in
                    for (index, data) in compressedImages.enumerated() {
                        
                        let filename = "review\(index).jpg"
                        
                        form.append(
                            data,
                            withName: "files",
                            fileName: filename,
                            mimeType: "image/jpeg"
                        )
                    }
                }
            }
        }
    }
}
