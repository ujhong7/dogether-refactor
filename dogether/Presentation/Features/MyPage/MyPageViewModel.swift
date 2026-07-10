//
//  MyPageViewModel.swift
//  dogether
//
//  Created by yujaehong on 5/17/25.
//

import RxCocoa
import RxRelay

@MainActor
final class MyPageViewModel {
    struct Output {
        let profileViewDatas: Driver<ProfileViewDatas>
        let statsButtonViewDatas: Driver<DogetherButtonViewDatas>
    }

    private let userUseCase: UserUseCase
    
    private let profileViewDatas = BehaviorRelay<ProfileViewDatas>(value: ProfileViewDatas())
    private let statsButtonViewDatas = BehaviorRelay<DogetherButtonViewDatas>(value: DogetherButtonViewDatas())
    
    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }

    var output: Output {
        Output(
            profileViewDatas: profileViewDatas.asDriver(),
            statsButtonViewDatas: statsButtonViewDatas.asDriver()
        )
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
