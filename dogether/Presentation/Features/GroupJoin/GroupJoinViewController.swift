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
        self.viewModel.updateIsFirstResponder(isFirstResponder: true)
    }
    
    override func setViewDatas() {
        if let datas = datas as? GroupJoinViewDatas {
            self.viewModel.groupJoinViewDatas.accept(datas)
        }
        
        bind(self.viewModel.groupJoinViewDatas)
        bind(self.viewModel.joinButtonViewDatas)
    }
}

protocol GroupJoinDelegate {
    func updateCodeAction(code: String)
    func updateButtonStatusAction(status: ButtonStatus)
    func updateKeyboardHeightAction(height: CGFloat)
    func joinGroupAction()
}

extension GroupJoinViewController: GroupJoinDelegate {
    func updateCodeAction(code: String) {
        self.viewModel.updateCode(code: code)
    }
    
    func updateButtonStatusAction(status: ButtonStatus) {
        self.viewModel.updateButtonStatus(status: status)
    }
    
    func updateKeyboardHeightAction(height: CGFloat) {
        self.viewModel.updateKeyboardHeight(height: height)
    }
    
    func joinGroupAction() {
        runTask { [self] in
            let groupInfo = try await self.viewModel.joinGroup()
            self.coordinator?.setNavigationController(
                CompleteViewController(),
                datas: CompleteViewDatas(
                    groupType: .join,
                    groupEntity: groupInfo
                )
            )
        } catch: { [weak self] error in
            if let error = error as? NetworkError, case let .dogetherError(code, _) = error {
                guard let alertType: AlertTypes =
                        code == .CGF0002 ? .alreadyParticipated :
                            code == .CGF0003 ? .fullGroup :
                            code == .CGF0004 || code == .CGF0005 ? .unableToParticipate :
                            nil else { return }
                
                self?.coordinator?.showPopup(type: .alert, alertType: alertType) { [weak self] _ in
                    guard let self else { return }
                    self.coordinator?.popViewController()
                }
            }
        }
    }
}
