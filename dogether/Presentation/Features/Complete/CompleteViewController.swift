//
//  CompleteViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/12/25.
//

import UIKit

import RxCocoa
import RxSwift

final class CompleteViewController: BaseViewController {
    private let completePage = CompletePage()
    private let viewModel = CompleteViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        pages = [completePage]
        super.viewDidLoad()
    }
    
    override func setViewDatas() {
        if let datas = datas as? CompleteViewDatas {
            self.viewModel.setDatas(datas)
        }

        let output = viewModel.output
        bind(output.completeViewDatas, update: completePage.updateComplete)

        completePage.homeTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.coordinator?.setMain()
            })
            .disposed(by: disposeBag)

        completePage.shareJoinCodeTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.shareJoinCode()
            })
            .disposed(by: disposeBag)
    }
}

extension CompleteViewController {
    private func shareJoinCode() {
        let data = self.viewModel.currentDatas

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
