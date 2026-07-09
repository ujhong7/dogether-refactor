//
//  SettingViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import Foundation

final class SettingViewController: BaseViewController {
    private let settingPage = SettingPage()
    private let viewModel: SettingViewModel

    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        settingPage.delegate = self
        
        pages = [settingPage]
        
        super.viewDidLoad()
    }
}

// MARK: - delegate
@MainActor
protocol SettingDelegate {
    func logoutAction()
    func withdrawAction()
}

extension SettingViewController: SettingDelegate {
    func logoutAction() {
        coordinator?.showPopup(type: .alert, alertType: .logout) { [weak self] _ in
            guard let self else { return }
            viewModel.logout()
            guard let coordinator else { return }
            coordinator.setOnboarding()
        }
    }
    
    func withdrawAction() {
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
