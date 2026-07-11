//
//  GroupCreateViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/9/25.
//

import UIKit

import RxCocoa
import RxRelay
import RxSwift

final class GroupCreateViewController: BaseViewController {
    private let groupCreatePage = GroupCreatePage()
    private let viewModel: GroupCreateViewModel
    private let viewDidAppearRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    init(viewModel: GroupCreateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [groupCreatePage]

        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearRelay.accept(())
    }
    
    override func setViewDatas() {
        let input = GroupCreateViewModel.Input(
            viewDidAppear: viewDidAppearRelay.asSignal(),
            stepChanged: groupCreatePage.stepChanged.asSignal(),
            groupNameChanged: groupCreatePage.groupNameChanged.asSignal(),
            memberCountChanged: groupCreatePage.memberCountChanged.asSignal(),
            durationSelected: groupCreatePage.durationSelected.asSignal(),
            startAtSelected: groupCreatePage.startAtSelected.asSignal()
        )
        let output = viewModel.transform(input: input)
        bind(output.groupCreateViewDatas, update: groupCreatePage.updateGroupCreate)

        groupCreatePage.createTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.createGroup()
            })
            .disposed(by: disposeBag)
    }
}

extension GroupCreateViewController {
    private func createGroup() {
        runTask { [weak self] in
            guard let self else { return }
            let joinCode = try await viewModel.createGroup()
            guard let coordinator else { return }
            let completeViewDatas = CompleteViewDatas(
                groupType: .create,
                joinCode: joinCode,
                groupEntity: GroupEntity(
                    name: viewModel.groupName
                )
            )
            coordinator.setComplete(datas: completeViewDatas)
        }
    }
}
