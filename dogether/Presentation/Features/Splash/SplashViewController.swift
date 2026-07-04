//
//  SplashViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/15/25.
//

final class SplashViewController: BaseViewController {
    private let splashPage = SplashPage()
    private let viewModel = SplashViewModel()
    
    override func viewDidLoad() {
        pages = [splashPage]
        
        super.viewDidLoad()
        
        onAppear()
    }
}

extension SplashViewController {
    private func onAppear() {
        runTask { [self] in
            try await self.viewModel.launchApp()

            if try await self.viewModel.checkUpdate() {
                self.coordinator?.setNavigationController(UpdateViewController())
                return
            }

            if self.viewModel.checkLogin() {
                self.coordinator?.setNavigationController(OnboardingViewController())
                return
            }

            if try await self.viewModel.checkParticipating() {
                self.coordinator?.setNavigationController(StartViewController())
            } else {
                self.coordinator?.setNavigationController(MainViewController())
            }
        }
    }
}
