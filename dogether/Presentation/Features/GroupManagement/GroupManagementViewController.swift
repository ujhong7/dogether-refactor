//
//  GroupManagementViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import Foundation

final class GroupManagementViewController: BaseViewController {
    private let groupManagementPage = GroupManagementPage()
    private let viewModel: GroupManagementViewModel

    init(viewModel: GroupManagementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        groupManagementPage.delegate = self
        
        pages = [groupManagementPage]
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadGroups()
        
        coordinator?.updateViewController = loadGroups
    }

    override func setViewDatas() {
        bind(viewModel.groupManagementViewDatas)
    }
}

extension GroupManagementViewController {
    private func loadGroups() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.loadGroups()
        }
    }
}

// MARK: - delegate
@MainActor
protocol GroupManagementDelegate: AnyObject {
    func leaveGroupAction(_ group: GroupEntity)
    func addGroupAction()
}

extension GroupManagementViewController: GroupManagementDelegate {
    func leaveGroupAction(_ group: GroupEntity) {
        coordinator?.showPopup(type: .alert, alertType: .leaveGroup) { [weak self] _ in
            guard let self else { return }
            runTask { [weak self] in
                guard let self else { return }
                try await viewModel.leaveGroup(groupId: group.id)
                try await viewModel.loadGroups()
            }
        }
    }
    
    func addGroupAction() {
        guard let coordinator else { return }
        coordinator.pushViewController(coordinator.appFactory.makeGroupCreateViewController())
    }
}
