//
//  MyPageViewController.swift
//  dogether
//
//  Created by seungyooooong on 3/31/25.
//

import UIKit

import RxCocoa
import RxSwift

final class MyPageViewController: BaseViewController {
    private let myPage = MyPagePage()
    private let viewModel: MyPageViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [myPage]
        
        super.viewDidLoad()
        
        onAppear()
    }
    
    override func setViewDatas() {
        let output = viewModel.output
        bind(output.profileViewDatas, update: myPage.updateView)
        bind(output.statsButtonViewDatas, update: myPage.updateView)

        myPage.statsTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.coordinator?.pushStats()
            })
            .disposed(by: disposeBag)

        myPage.certificationListTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.coordinator?.pushCertificationList()
            })
            .disposed(by: disposeBag)

        myPage.groupManagementTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.coordinator?.pushGroupManagement()
            })
            .disposed(by: disposeBag)

        myPage.settingTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.coordinator?.pushSetting()
            })
            .disposed(by: disposeBag)
    }
}

extension MyPageViewController {
    private func onAppear() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.loadProfileView()
        }
    }
}
