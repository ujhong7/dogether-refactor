//
//  SettingViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import Foundation

final class SettingViewController: BaseViewController {
    private let settingPage = SettingPage()
    private let viewModel = SettingViewModel()
    
    override func viewDidLoad() {
        settingPage.delegate = self
        
        pages = [settingPage]
        
        super.viewDidLoad()
    }
}

// MARK: - delegate
protocol SettingDelegate {
    func logoutAction()
    func withdrawAction()
}

extension SettingViewController: SettingDelegate {
    func logoutAction() {
        self.coordinator?.showPopup(type: .alert, alertType: .logout) { [weak self] _ in
            guard let self else { return }
            self.viewModel.logout()
            self.coordinator?.setNavigationController(OnboardingViewController())
        }
    }
    
    func withdrawAction() {
        self.coordinator?.showPopup(type: .alert, alertType: .withdraw) { [weak self] _ in
            guard let self else { return }
            runTask { [self] in
                try await self.viewModel.withdraw()
                self.viewModel.logout()
                self.coordinator?.setNavigationController(OnboardingViewController())
            }
        }
    }
}
