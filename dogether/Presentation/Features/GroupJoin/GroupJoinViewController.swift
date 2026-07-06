//
//  GroupJoinViewController.swift
//  dogether
//
//  Created by seungyooooong on 11/19/25.
//

import UIKit

final class GroupJoinViewController: BaseViewController {
    private let groupJoinPage = GroupJoinPage()
    private let viewModel = GroupJoinViewModel()
    
    override func viewDidLoad() {
        groupJoinPage.delegate = self
        
        pages = [groupJoinPage]
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.updateIsFirstResponder(isFirstResponder: true)
    }
    
    override func setViewDatas() {
        if let datas = datas as? GroupJoinViewDatas {
            viewModel.groupJoinViewDatas.accept(datas)
        }
        
        bind(viewModel.groupJoinViewDatas)
        bind(viewModel.joinButtonViewDatas)
    }
}

@MainActor
protocol GroupJoinDelegate {
    func updateCodeAction(code: String)
    func updateButtonStatusAction(status: ButtonStatus)
    func updateKeyboardHeightAction(height: CGFloat)
    func joinGroupAction()
}

extension GroupJoinViewController: GroupJoinDelegate {
    func updateCodeAction(code: String) {
        viewModel.updateCode(code: code)
    }
    
    func updateButtonStatusAction(status: ButtonStatus) {
        viewModel.updateButtonStatus(status: status)
    }
    
    func updateKeyboardHeightAction(height: CGFloat) {
        viewModel.updateKeyboardHeight(height: height)
    }
    
    func joinGroupAction() {
        runTask(onAlertComplete: { [weak self] alertType in
            switch alertType {
            case .alreadyParticipated, .fullGroup, .unableToParticipate:
                self?.coordinator?.popViewController()
            default:
                break
            }
        }) { [weak self] in
            guard let self else { return }
            let groupInfo = try await viewModel.joinGroup()
            coordinator?.setNavigationController(
                CompleteViewController(),
                datas: CompleteViewDatas(
                    groupType: .join,
                    groupEntity: groupInfo
                )
            )
        }
    }
}
