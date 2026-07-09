//
//  OnboardingViewController.swift
//  dogether
//
//  Created by seungyooooong on 3/25/25.
//

import UIKit

import RxCocoa
import RxSwift

final class OnboardingViewController: BaseViewController {
    private let onboardingPage = OnboardingPage()
    private let viewModel: OnboardingViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [onboardingPage]
        
        super.viewDidLoad()

        bindActions()
    }
}

extension OnboardingViewController {
    private func bindActions() {
        onboardingPage.loginTapped
            .asSignal()
            .emit(onNext: { [weak self] loginType in
                self?.login(loginType: loginType)
            })
            .disposed(by: disposeBag)
    }

    private func login(loginType: LoginTypes) {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.login(loginType: loginType)

            if try await viewModel.checkParticipating() {
                guard let coordinator else { return }
                coordinator.setStart()
                return
            }

            guard let coordinator else { return }
            coordinator.setMain()
        }
    }
}
