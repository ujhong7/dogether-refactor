//
//  GroupManagementViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import Foundation

final class GroupManagementViewController: BaseViewController {
    private let groupManagementPage = GroupManagementPage()
    private let viewModel = GroupManagementViewModel()

    override func viewDidLoad() {
        groupManagementPage.delegate = self
        
        pages = [groupManagementPage]
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadGroups()
        
        self.coordinator?.updateViewController = loadGroups
    }

    override func setViewDatas() {
        bind(self.viewModel.groupManagementViewDatas)
    }
}

extension GroupManagementViewController {
    private func loadGroups() {
        runTask { [self] in
            try await self.viewModel.loadGroups()
        }
    }
}

// MARK: - delegate
protocol GroupManagementDelegate: AnyObject {
    func leaveGroupAction(_ group: GroupEntity)
    func addGroupAction()
}

extension GroupManagementViewController: GroupManagementDelegate {
    func leaveGroupAction(_ group: GroupEntity) {
        self.coordinator?.showPopup(type: .alert, alertType: .leaveGroup) { [weak self] _ in
            guard let self else { return }
            runTask { [self] in
                try await self.viewModel.leaveGroup(groupId: group.id)
                try await self.viewModel.loadGroups()
            }
        }
    }
    
    func addGroupAction() {
        self.coordinator?.pushViewController(GroupCreateViewController())
    }
}
