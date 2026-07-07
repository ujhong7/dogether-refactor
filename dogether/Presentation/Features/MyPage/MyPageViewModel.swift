//
//  MyPageViewModel.swift
//  dogether
//
//  Created by yujaehong on 5/17/25.
//

import RxRelay

@MainActor
final class MyPageViewModel {
    private let userUseCase: UserUseCase
    
    private(set) var profileViewDatas = BehaviorRelay<ProfileViewDatas>(value: ProfileViewDatas())
    private(set) var statsButtonViewDatas = BehaviorRelay<DogetherButtonViewDatas>(value: DogetherButtonViewDatas())
    
    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }
}

extension MyPageViewModel {
    func loadProfileView() async throws {
        try await fetchMyProfile()
    }
    
    func fetchMyProfile() async throws {
        profileViewDatas.accept(try await userUseCase.getProfileViewDatas())
    }
}
