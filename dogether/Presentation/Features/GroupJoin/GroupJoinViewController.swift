//
//  GroupJoinViewController.swift
//  dogether
//
//  Created by seungyooooong on 11/19/25.
//

import UIKit

import RxCocoa
import RxRelay
import RxSwift

final class GroupJoinViewController: BaseViewController {
    private let groupJoinPage = GroupJoinPage()
    private let viewModel: GroupJoinViewModel
    private let viewDidAppearRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    init(viewModel: GroupJoinViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [groupJoinPage]
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearRelay.accept(())
    }
    
    override func setViewDatas() {
        if let datas = datas as? GroupJoinViewDatas {
            viewModel.setDatas(datas)
        }
        
        let input = GroupJoinViewModel.Input(
            viewDidAppear: viewDidAppearRelay.asSignal(),
            codeChanged: groupJoinPage.codeChanged.asSignal(),
            keyboardHeightChanged: groupJoinPage.keyboardHeightChanged.asSignal()
        )
        let output = viewModel.transform(input: input)
        bind(output.groupJoinViewDatas, update: groupJoinPage.updateView)
        bind(output.joinButtonViewDatas, update: groupJoinPage.updateView)

        groupJoinPage.joinTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.joinGroup()
            })
            .disposed(by: disposeBag)
    }
}

extension GroupJoinViewController {
    private func joinGroup() {
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
            guard let coordinator else { return }
            coordinator.setComplete(
                datas: CompleteViewDatas(
                    groupType: .join,
                    groupEntity: groupInfo
                )
            )
        }
    }
}
