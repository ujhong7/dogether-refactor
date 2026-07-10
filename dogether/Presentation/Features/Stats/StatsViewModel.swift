//
//  StatsViewModel.swift
//  dogether
//
//  Created by yujaehong on 4/22/25.
//

import Foundation
import RxCocoa
import RxRelay

@MainActor
final class StatsViewModel {
    struct Output {
        let bottomSheetViewDatas: Driver<BottomSheetViewDatas>
        let groupViewDatas: Driver<GroupViewDatas>
        let achievementViewDatas: Driver<AchievementViewDatas>
        let myRankViewDatas: Driver<StatsRankViewDatas>
        let summaryViewDatas: Driver<StatsSummaryViewDatas>
    }

    private let userUseCase: UserUseCase
    private let groupUseCase: GroupUseCase
    
    private let bottomSheetViewDatas = BehaviorRelay<BottomSheetViewDatas>(value: BottomSheetViewDatas())
    private let groupViewDatas = BehaviorRelay<GroupViewDatas>(value: GroupViewDatas())
    private let achievementViewDatas = BehaviorRelay<AchievementViewDatas>(value: AchievementViewDatas())
    private let myRankViewDatas = BehaviorRelay<StatsRankViewDatas>(value: StatsRankViewDatas())
    private let summaryViewDatas = BehaviorRelay<StatsSummaryViewDatas>(value: StatsSummaryViewDatas())
    
    // MARK: - Computed
    var currentGroup: GroupEntity { groupViewDatas.value.groups[groupViewDatas.value.index] }
    
    init(userUseCase: UserUseCase, groupUseCase: GroupUseCase) {
        self.userUseCase = userUseCase
        self.groupUseCase = groupUseCase
    }

    var output: Output {
        Output(
            bottomSheetViewDatas: bottomSheetViewDatas.asDriver(),
            groupViewDatas: groupViewDatas.asDriver(),
            achievementViewDatas: achievementViewDatas.asDriver(),
            myRankViewDatas: myRankViewDatas.asDriver(),
            summaryViewDatas: summaryViewDatas.asDriver()
        )
    }
}

extension StatsViewModel {
    func loadStatsView() async throws {
        try await fetchMyGroups()
    }
}

extension StatsViewModel {
    private func fetchMyGroups() async throws {
        let (groupIndex, groups) = try await groupUseCase.getGroups()
        
        guard let groupIndex else { return }
        groupViewDatas.accept(GroupViewDatas(index: groupIndex, groups: groups))
        
        try await fetchStatsViewDatas()
    }
}

extension StatsViewModel {
    func fetchStatsViewDatas() async throws {
        let (achievement, myRank, summary) = try await userUseCase.getStatsViewDatas(groupId: currentGroup.id)
        
        achievementViewDatas.accept(achievement)
        myRankViewDatas.accept(myRank)
        summaryViewDatas.accept(summary)
    }
}

extension StatsViewModel {
    func updateBottomSheetVisible(isShowSheet: Bool) {
        bottomSheetViewDatas.update { $0.isShowSheet = isShowSheet }
    }

    func selectGroup(index: Int) {
        groupViewDatas.update { $0.index = index }
    }

    func saveLastSelectedGroupIndex(index: Int) async throws {
        try await groupUseCase.saveLastSelectedGroup(groupId: groupViewDatas.value.groups[index].id)
    }
}
