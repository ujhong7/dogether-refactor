//
//  AuthUseCase.swift
//  dogether
//
//  Created by seungyooooong on 3/25/25.
//

import Foundation

import AuthenticationServices
import FirebaseMessaging

enum AuthError: Error {
    case missingCredential  // 애플 자격 증명 누락
    case duplicatedRequest  // 이전 요청이 끝나기 전 새 요청이 들어온 경우
}

@MainActor
final class AuthUseCase: NSObject {
    private let repository: AuthProtocol

    private typealias AppleAuthInfo = (idToken: String, name: String?, authorizationCode: String)
    private var continuation: CheckedContinuation<AppleAuthInfo, Error>?
    private var authorizationController: ASAuthorizationController?

    init(repository: AuthProtocol) {
        self.repository = repository
    }
}

extension AuthUseCase: ASAuthorizationControllerDelegate {
    /// apple server에 login 요청을 보내고 결과를 async로 반환하는 함수입니다.
    ///
    /// 기본적으로 fullName을 요청합니다. (fullName은 최초 1회 로그인에만 전달됨)
    private func requestAppleLogin() async throws -> AppleAuthInfo {
        try await withCheckedThrowingContinuation { continuation in
            guard self.continuation == nil else {
                continuation.resume(throwing: AuthError.duplicatedRequest)
                return
            }
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            self.authorizationController = controller
            controller.performRequests()
        }
    }

    private func resume(returning value: AppleAuthInfo) {
        continuation?.resume(returning: value)
        continuation = nil
        authorizationController = nil
    }

    private func resume(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
        authorizationController = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard controller === authorizationController else { return }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8),
              let authorizationCodeData = appleIDCredential.authorizationCode,
              let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) else {
            resume(throwing: AuthError.missingCredential)
            return
        }

        // MARK: fullName은 최초 로그인에만 전달되므로 nil을 허용합니다
        let fullName = appleIDCredential.fullName
        let name: String?
        if let fullName, fullName.familyName != nil || fullName.givenName != nil {
            name = (fullName.familyName ?? "") + (fullName.givenName ?? "")
        } else {
            name = nil
        }

        resume(returning: (idToken, name, authorizationCode))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard controller === authorizationController else { return }

        resume(throwing: error)
    }
}

extension AuthUseCase {
    func login(loginType: LoginTypes) async throws {
        switch loginType {
        case .apple:
            let userInfo = try await requestAppleLogin()
            let (userFullName, accessToken) = try await repository.login(
                loginType: loginType,
                providerId: userInfo.idToken,
                name: userInfo.name
            )

            try await setUserDefaults(loginType: loginType, userFullName: userFullName, accessToken: accessToken)
        case .kakao:
            return // FIXME: 추후 카카오 확장 필요
        }
    }

    private func setUserDefaults(loginType: LoginTypes, userFullName: String, accessToken: String) async throws {
        UserDefaultsManager.shared.loginType = loginType.rawValue
        UserDefaultsManager.shared.userFullName = userFullName
        UserDefaultsManager.shared.accessToken = accessToken

        let token = try await Messaging.messaging().token()
        let saveNotiTokenRequest = SaveNotiTokenRequest(token: token)
        try await repository.saveNotiToken(saveNotiTokenRequest: saveNotiTokenRequest)

        // FIXME: code NTS-0001 case handling
        UserDefaultsManager.shared.fcmToken = token
    }
}

extension AuthUseCase {
    func logout() {
        UserDefaultsManager.logout()
    }

    func withdraw() async throws {
        guard let userDefaultLoginType = UserDefaultsManager.shared.loginType,
              let loginType = LoginTypes(rawValue: userDefaultLoginType) else { return }

        switch loginType {
        case .apple:
            let userInfo = try await requestAppleLogin()
            try await repository.withdraw(loginType: loginType, authorizationCode: userInfo.authorizationCode)
        case .kakao:
            return // FIXME: 추후 카카오 확장 필요
        }
    }
}
