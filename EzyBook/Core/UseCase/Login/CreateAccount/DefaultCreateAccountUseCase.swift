//
//  DefaultCreateAccountUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

final class DefaultCreateAccountUseCase {
    
    private let networkManager: NetworkRepository
    
    init(networkManager: NetworkRepository) {
        self.networkManager = networkManager
    }
    
}

// MARK: 네트워크 통신 요청
extension DefaultCreateAccountUseCase {
    
    /// 이메일 중복확인 (서버 통신)
    func verifyEmailAvailability(_ email: String, completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        let body = EmailValidationRequestDTO(email: email)
        let router = UserRequest.emailValidation(body: body)
        Task {
            do {
                _ = try await networkManager.fetchData(dto: EmailValidationResponseDTO.self, router)
                await MainActor.run {
                    completionHandler(.success(()))
                }
            } catch {
                if let apiError = error as? APIError {
                    await MainActor.run {
                        completionHandler(.failure(apiError))
                    }
                } else {
                    await MainActor.run {
                        completionHandler(.failure(.unknown))
                    }
                }
            }
        }

    }
    
    /// 이메일 중복확인 (서버 통신)
    func signUp(_ router: UserRequest, completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        Task {
            do {
                let _ = try await networkManager.fetchData(dto: JoinResponseDTO.self, router)
                await MainActor.run {
                    completionHandler(.success(()))
                }
            } catch {
                if let apiError = error as? APIError {
                    await MainActor.run {
                        completionHandler(.failure(.unknown))
                    }
                    completionHandler(.failure(apiError))
                } else {
                    await MainActor.run {
                        completionHandler(.failure(.unknown))
                    }
                }
            }
        }
    }
    
}
