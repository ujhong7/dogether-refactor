//
//  GroupCreateViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/9/25.
//

import UIKit

final class GroupCreateViewController: BaseViewController {
    private let groupCreatePage = GroupCreatePage()
    private let viewModel: GroupCreateViewModel

    init(viewModel: GroupCreateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        groupCreatePage.delegate = self
        
        pages = [groupCreatePage]

        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.updateIsFirstResponder(isFirstResponder: true)
    }
    
    override func setViewDatas() {
        bind(viewModel.groupCreateViewDatas)
    }
}

// MARK: - delegate
@MainActor
protocol GroupCreateDelegate {
    func updateStep(step: CreateGroupSteps?)
    func updateGroupNameAction(groupName: String)
    func updateCountAction(currentCount: Int, min: Int, max: Int)
    func updateDuration(duration: GroupChallengeDurations)
    func updateStartAt(startAt: GroupStartAts)
    func createGroup()
}

extension GroupCreateViewController: GroupCreateDelegate {
    func updateStep(step: CreateGroupSteps?) {
        viewModel.updateStep(step: step)
    }
    
    func updateGroupNameAction(groupName: String) {
        viewModel.updateGroupName(groupName: groupName)
    }
    
    func updateCountAction(currentCount: Int, min: Int, max: Int) {
        viewModel.updateMemberCount(count: currentCount, min: min, max: max)
    }
    
    func updateDuration(duration: GroupChallengeDurations) {
        viewModel.updateDuration(duration: duration)
    }
    
    func updateStartAt(startAt: GroupStartAts) {
        viewModel.updateStartAt(startAt: startAt)
    }
    
    func createGroup() {
        runTask { [weak self] in
            guard let self else { return }
            let joinCode = try await viewModel.createGroup()
            guard let coordinator else { return }
            let completeViewDatas = CompleteViewDatas(
                groupType: .create,
                joinCode: joinCode,
                groupEntity: GroupEntity(
                    name: viewModel.groupCreateViewDatas.value.groupName
                )
            )
            coordinator.setComplete(datas: completeViewDatas)
        }
    }
}
