//
//  NetworkManager.swift
//  dogether
//
//  Created by seungyooooong on 1/27/25.
//

import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private init() { }
    
    weak var coordinator: NavigationCoordinator?
    
    func request<T: Decodable>(_ endpoint: NetworkEndpoint) async throws -> T {
        // MARK: 공통 에러 발생 시 에러 뷰의 "재시도" 입력을 기다렸다가 같은 요청을 반복합니다
        while true {
            await LoadingManager.shared.showLoading()

            do {
                let response: ServerResponse<T> = try await NetworkService.shared.request(endpoint)

                if T.self == EmptyData.self {
                    await LoadingManager.shared.hideLoading()
                    return EmptyData() as! T
                }

                guard let data = response.data else {
                    if let dogetherCode = DogetherCodes(rawValue: response.code) {
                        throw NetworkError.dogetherError(code: dogetherCode, message: response.message)
                    } else { throw NetworkError.unknown }
                }

                await LoadingManager.shared.hideLoading()
                return data
            } catch {
                await LoadingManager.shared.hideLoading()

                if checkCommonError(error) {
                    try await waitForRetry(error: error)
                    continue
                } else {
                    throw handleDetailError(error)
                }
            }
        }
    }
    
    func request(_ endpoint: NetworkEndpoint) async throws -> Void {
        let _: EmptyData = try await request(endpoint)
    }
}

// MARK: - handle error
extension NetworkManager {
    private func checkCommonError(_ error: Error) -> Bool {
        guard let error = error as? NetworkError, case let .dogetherError(code, _) = error else { return true }
        return !(code == .ATF0002 || code == .ATF0003 ||
                 code == .CGF0002 || code == .CGF0003 || code == .CGF0004 || code == .CGF0005)
    }
    
    /// 에러 뷰의 "재시도" 입력이 들어올 때까지 대기합니다.
    private func waitForRetry(error: Error) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            guard let coordinator else {
                continuation.resume(throwing: handleDetailError(error))
                return
            }
            coordinator.showErrorView {
                continuation.resume()
            }
        }
    }
    
    private func handleDetailError(_ error: Error) -> NetworkError {
        if let error = error as? NetworkError {
            if case let .dogetherError(code, _) = error, code == .ATF0003 {
                coordinator?.showPopup(type: .alert, alertType: .needLogout) { [weak self] _ in
                    guard let self else { return }
                    UserDefaultsManager.logout()
                    coordinator?.setNavigationController(OnboardingViewController())
                }
            }
            return error
        } else { return NetworkError.unknown }
    }
}
