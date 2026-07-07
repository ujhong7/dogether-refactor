//
//  OnboardingViewModel.swift
//  dogether
//
//  Created by seungyooooong on 3/25/25.
//

import RxRelay

@MainActor
final class OnboardingViewModel {
    private let authUseCase: AuthUseCase
    private let groupUseCase: GroupUseCase
    
    init(authUseCase: AuthUseCase, groupUseCase: GroupUseCase) {
        self.authUseCase = authUseCase
        self.groupUseCase = groupUseCase
    }

    func login(loginType: LoginTypes) async throws {
        try await authUseCase.login(loginType: loginType)
    }
    
    func checkParticipating() async throws -> Bool {
        try await groupUseCase.checkParticipating()
    }
}
