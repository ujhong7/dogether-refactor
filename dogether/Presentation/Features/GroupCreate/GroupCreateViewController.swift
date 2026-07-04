//
//  GroupCreateViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/9/25.
//

import UIKit

final class GroupCreateViewController: BaseViewController {
    private let groupCreatePage = GroupCreatePage()
    private let viewModel = GroupCreateViewModel()
    
    override func viewDidLoad() {
        groupCreatePage.delegate = self
        
        pages = [groupCreatePage]

        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewModel.updateIsFirstResponder(isFirstResponder: true)
    }
    
    override func setViewDatas() {
        bind(self.viewModel.groupCreateViewDatas)
    }
}

// MARK: - delegate
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
        self.viewModel.updateStep(step: step)
    }
    
    func updateGroupNameAction(groupName: String) {
        self.viewModel.updateGroupName(groupName: groupName)
    }
    
    func updateCountAction(currentCount: Int, min: Int, max: Int) {
        self.viewModel.updateMemberCount(count: currentCount, min: min, max: max)
    }
    
    func updateDuration(duration: GroupChallengeDurations) {
        self.viewModel.updateDuration(duration: duration)
    }
    
    func updateStartAt(startAt: GroupStartAts) {
        self.viewModel.updateStartAt(startAt: startAt)
    }
    
    func createGroup() {
        runTask { [self] in
            let joinCode = try await self.viewModel.createGroup()
            let completeViewController = CompleteViewController()
            let completeViewDatas = CompleteViewDatas(
                groupType: .create,
                joinCode: joinCode,
                groupEntity: GroupEntity(
                    name: self.viewModel.groupCreateViewDatas.value.groupName
                )
            )
            self.coordinator?.setNavigationController(completeViewController, datas: completeViewDatas)
        }
    }
}
