//
//  CompleteViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/12/25.
//

import UIKit

final class CompleteViewController: BaseViewController {
    private let completePage = CompletePage()
    private let viewModel = CompleteViewModel()
    
    override func viewDidLoad() {
        completePage.delegate = self
        pages = [completePage]
        super.viewDidLoad()
    }
    
    override func setViewDatas() {
        if let datas = datas as? CompleteViewDatas {
            self.viewModel.completeViewDatas.accept(datas)
        }

        bind(self.viewModel.completeViewDatas)
    }
}

@MainActor
protocol CompleteDelegate: AnyObject {
    func goHomeAction()
    func shareJoinCodeAction()
}

extension CompleteViewController: CompleteDelegate {
    func goHomeAction() {
        guard let coordinator else { return }
        coordinator.setMain()
    }
    
    func shareJoinCodeAction() {
        let data = self.viewModel.completeViewDatas.value

        runTask {
            try await SystemManager.inviteGroup(
                groupName: data.groupEntity.name,
                joinCode: data.joinCode
            )
        } success: { [weak self] inviteItems in
            let activityVC = UIActivityViewController(
                activityItems: inviteItems,
                applicationActivities: nil
            )
            self?.present(activityVC, animated: true)
        }
    }
}
