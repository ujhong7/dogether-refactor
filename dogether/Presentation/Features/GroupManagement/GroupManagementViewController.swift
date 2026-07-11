//
//  GroupManagementViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import Foundation

import RxCocoa
import RxSwift

final class GroupManagementViewController: BaseViewController {
    private let groupManagementPage = GroupManagementPage()
    private let viewModel: GroupManagementViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: GroupManagementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        pages = [groupManagementPage]
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadGroups()
        
        coordinator?.setRefreshAction(loadGroups)
    }

    override func setViewDatas() {
        let output = viewModel.output
        bind(output.groupManagementViewDatas, update: groupManagementPage.updateGroupManagement)

        groupManagementPage.addGroupTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.coordinator?.pushGroupCreate()
            })
            .disposed(by: disposeBag)

        groupManagementPage.leaveGroupTapped
            .asSignal()
            .emit(onNext: { [weak self] group in
                self?.leaveGroup(group)
            })
            .disposed(by: disposeBag)
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

extension GroupManagementViewController {
    private func leaveGroup(_ group: GroupEntity) {
        coordinator?.showPopup(type: .alert, alertType: .leaveGroup) { [weak self] _ in
            guard let self else { return }
            runTask { [weak self] in
                guard let self else { return }
                try await viewModel.leaveGroup(groupId: group.id)
                try await viewModel.loadGroups()
            }
        }
    }
}
