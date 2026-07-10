//
//  RankingViewModel.swift
//  dogether
//
//  Created by seungyooooong on 4/10/25.
//

import UIKit

import RxCocoa
import RxRelay

@MainActor
final class RankingViewModel {
    struct Output {
        let rankingViewDatas: Driver<RankingViewDatas>
    }

    private let groupUseCase: GroupUseCase
    private let challengeGroupsUseCase: ChallengeGroupUseCase
    
    private let rankingViewDatas = BehaviorRelay<RankingViewDatas>(value: RankingViewDatas())

    var groupId: Int { rankingViewDatas.value.groupId }
    
    init(groupUseCase: GroupUseCase, challengeGroupsUseCase: ChallengeGroupUseCase) {
        self.groupUseCase = groupUseCase
        self.challengeGroupsUseCase = challengeGroupsUseCase
    }

    var output: Output {
        Output(rankingViewDatas: rankingViewDatas.asDriver())
    }

    func setDatas(_ datas: RankingViewDatas) {
        rankingViewDatas.accept(datas)
    }
}

extension RankingViewModel {
    func loadRankingView() async throws {
        try await getRankings()
    }
}

extension RankingViewModel {
    func getRankings() async throws {
        let rankings = try await groupUseCase.getRankings(groupId: rankingViewDatas.value.groupId)
        rankingViewDatas.update { $0.rankings = rankings }
    }
    
    func getMemberTodos(memberId: Int) async throws -> (Int, [TodoEntity]) {
        try await challengeGroupsUseCase.getMemberTodos(groupId: rankingViewDatas.value.groupId, memberId: memberId)
    }
}
