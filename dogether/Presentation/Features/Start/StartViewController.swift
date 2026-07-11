//
//  StartViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/9/25.
//

import RxCocoa
import RxSwift

final class StartViewController: BaseViewController {
    private let startPage = StartPage()
    private let viewModel = StartViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        pages = [startPage]
        
        super.viewDidLoad()
        
        onAppear()
    }
    
    override func setViewDatas() {
        if let datas = datas as? StartViewDatas {
            viewModel.setDatas(datas)
        }

        let output = viewModel.output
        bind(output.startViewDatas, update: startPage.updateView)

        startPage.groupTypeSelected
            .asSignal()
            .emit(onNext: { [weak self] groupType in
                self?.start(groupType)
            })
            .disposed(by: disposeBag)
    }
}

extension StartViewController {
    private func onAppear() {
        if let code = DeepLinkManager.shared.consumeInviteCode() {
            guard let coordinator else { return }
            let groupJoinViewDatas = GroupJoinViewDatas(code: code)
            coordinator.pushGroupJoin(datas: groupJoinViewDatas)
        }
    }
}

extension StartViewController {
    private func start(_ groupType: GroupTypes) {
        guard let coordinator else { return }

        switch groupType {
        case .create:
            coordinator.pushGroupCreate()
        case .join:
            coordinator.pushGroupJoin()
        }
    }
}
