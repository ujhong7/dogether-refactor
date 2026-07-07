//
//  GroupManagementViewModel.swift
//  dogether
//
//  Created by yujaehong on 4/22/25.
//

import RxRelay

@MainActor
final class GroupManagementViewModel {
    private let groupUseCase: GroupUseCase
    
    private(set) var groupManagementViewDatas = BehaviorRelay<GroupManagementViewDatas>(value: GroupManagementViewDatas())
    
    init(groupUseCase: GroupUseCase) {
        self.groupUseCase = groupUseCase
    }
}

extension GroupManagementViewModel {
    func loadGroups() async throws {
        let (_, groups) = try await groupUseCase.getGroups()
        groupManagementViewDatas.update { $0.groups = groups }
    }
    
    func leaveGroup(groupId: Int) async throws {
        try await groupUseCase.leaveGroup(groupId: groupId)
    }
}
