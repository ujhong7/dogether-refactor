//
//  SettingViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import Foundation

import RxCocoa
import RxSwift

final class SettingViewController: BaseViewController {
    private let settingPage = SettingPage()
    private let viewModel: SettingViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [settingPage]
        
        super.viewDidLoad()

        bindActions()
    }
}

extension SettingViewController {
    private func bindActions() {
        settingPage.logoutTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.logout()
            })
            .disposed(by: disposeBag)

        settingPage.withdrawTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.withdraw()
            })
            .disposed(by: disposeBag)
    }

    private func logout() {
        coordinator?.showPopup(type: .alert, alertType: .logout) { [weak self] _ in
            guard let self else { return }
            viewModel.logout()
            guard let coordinator else { return }
            coordinator.setOnboarding()
        }
    }
    
    private func withdraw() {
        coordinator?.showPopup(type: .alert, alertType: .withdraw) { [weak self] _ in
            guard let self else { return }
            runTask { [weak self] in
                guard let self else { return }
                try await viewModel.withdraw()
                viewModel.logout()
                guard let coordinator else { return }
                coordinator.setOnboarding()
            }
        }
    }
}
