//
//  ReViewRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import SwiftUI
import Alamofire

enum ReViewRequest {
 
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
extension ReViewRequest {
    
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


// MARK: MultiPart
extension ReViewRequest {
    
    enum Multipart: MultipartRouter {
       
        case reviewFiles(id: String,image: [UIImage])
         
        var requiresAuth: Bool {
            return false
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
        
        var multipartFormData: ((MultipartFormData) -> Void)? {
            switch self {
            case .reviewFiles(_, let images):
                return { form in
                    for (index, image) in images.enumerated() {
                        if let data = image.compressedJPEGData(maxSizeInBytes: 1_000_000) {
                            form.append(
                                data,
                                withName: "files",
                                fileName: "review\(index).jpg",
                                mimeType: "image/jpeg"
                            )
                        }
                    }
                }
            }
        }
    }
}
