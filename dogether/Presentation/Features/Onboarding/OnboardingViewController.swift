//
//  OnboardingViewController.swift
//  dogether
//
//  Created by seungyooooong on 3/25/25.
//

final class OnboardingViewController: BaseViewController {
    private let onboardingPage = OnboardingPage()
    private let viewModel = OnboardingViewModel()
    
    override func viewDidLoad() {
        onboardingPage.delegate = self
        
        pages = [onboardingPage]
        
        super.viewDidLoad()
    }
}

// MARK: - delegate
protocol OnboardingDelegate {
    func loginAction(loginType: LoginTypes)
}

extension OnboardingViewController: OnboardingDelegate {
    func loginAction(loginType: LoginTypes) {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.login(loginType: loginType)

            if try await viewModel.checkParticipating() {
                coordinator?.setNavigationController(StartViewController())
                return
            }

            coordinator?.setNavigationController(MainViewController())
        } catch: { [weak self] error in
            if let error = error as? NetworkError, case let .dogetherError(code, _) = error {
                if code == .ATF0002 {
                    self?.coordinator?.showPopup(type: .alert, alertType: .needRevoke)
                }
            }
        }
    }
}
