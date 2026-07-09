//
//  SplashViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/15/25.
//

import UIKit

final class SplashViewController: BaseViewController {
    private let splashPage = SplashPage()
    private let viewModel: SplashViewModel

    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [splashPage]
        
        super.viewDidLoad()
        
        onAppear()
    }
}

extension SplashViewController {
    private func onAppear() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.launchApp()

            if try await viewModel.checkUpdate() {
                guard let coordinator else { return }
                coordinator.setUpdate()
                return
            }

            if viewModel.checkLogin() {
                guard let coordinator else { return }
                coordinator.setOnboarding()
                return
            }

            if try await viewModel.checkParticipating() {
                guard let coordinator else { return }
                coordinator.setStart()
            } else {
                guard let coordinator else { return }
                coordinator.setMain()
            }
        }
    }
}
