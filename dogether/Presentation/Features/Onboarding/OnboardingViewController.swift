//
//  OnboardingViewController.swift
//  dogether
//
//  Created by seungyooooong on 3/25/25.
//

import UIKit

final class OnboardingViewController: BaseViewController {
    private let onboardingPage = OnboardingPage()
    private let viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        onboardingPage.delegate = self
        
        pages = [onboardingPage]
        
        super.viewDidLoad()
    }
}

// MARK: - delegate
@MainActor
protocol OnboardingDelegate {
    func loginAction(loginType: LoginTypes)
}

extension OnboardingViewController: OnboardingDelegate {
    func loginAction(loginType: LoginTypes) {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.login(loginType: loginType)

            if try await viewModel.checkParticipating() {
                guard let coordinator else { return }
                coordinator.setNavigationController(coordinator.appFactory.makeStartViewController())
                return
            }

            guard let coordinator else { return }
            coordinator.setNavigationController(coordinator.appFactory.makeMainViewController())
        }
    }
}
