//
//  NavigationCoordinator.swift
//  dogether
//
//  Created by seungyooooong on 3/21/25.
//

import UIKit

@MainActor
final class NavigationCoordinator: NSObject, NavigationCoordinating {
    let navigationController: UINavigationController
    let todoCertificationsUseCase: TodoCertificationsUseCase

    private let appFactory: AppFactory

    var modalityWindow: UIWindow?
    var refreshAction: (() -> Void)?

    var lastViewController: UIViewController? {
        if let modalityWindow { return modalityWindow.rootViewController }
        return navigationController.viewControllers.last
    }

    init(
        navigationController: UINavigationController,
        appFactory: AppFactory,
        todoCertificationsUseCase: TodoCertificationsUseCase
    ) {
        self.navigationController = navigationController
        self.appFactory = appFactory
        self.todoCertificationsUseCase = todoCertificationsUseCase
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLastAccessDate),
            name: .NSCalendarDayChanged, object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSCalendarDayChanged, object: nil)
    }
}

extension NavigationCoordinator {
    func makeSplashViewController() -> SplashViewController {
        appFactory.makeSplashViewController()
    }

    func makeOnboardingViewController() -> OnboardingViewController {
        appFactory.makeOnboardingViewController()
    }

    func makeStartViewController() -> StartViewController {
        appFactory.makeStartViewController()
    }

    func makeMainViewController() -> MainViewController {
        appFactory.makeMainViewController()
    }

    func makeUpdateViewController() -> UpdateViewController {
        appFactory.makeUpdateViewController()
    }

    func makeCompleteViewController() -> CompleteViewController {
        appFactory.makeCompleteViewController()
    }

    func makeGroupJoinViewController() -> GroupJoinViewController {
        appFactory.makeGroupJoinViewController()
    }

    func makeGroupCreateViewController() -> GroupCreateViewController {
        appFactory.makeGroupCreateViewController()
    }

    func makeMyPageViewController() -> MyPageViewController {
        appFactory.makeMyPageViewController()
    }

    func makeStatsViewController() -> StatsViewController {
        appFactory.makeStatsViewController()
    }

    func makeCertificationListViewController() -> CertificationListViewController {
        appFactory.makeCertificationListViewController()
    }

    func makeGroupManagementViewController() -> GroupManagementViewController {
        appFactory.makeGroupManagementViewController()
    }

    func makeSettingViewController() -> SettingViewController {
        appFactory.makeSettingViewController()
    }

    func makeRankingViewController() -> RankingViewController {
        appFactory.makeRankingViewController()
    }

    func makeCertificationViewController() -> CertificationViewController {
        appFactory.makeCertificationViewController()
    }

    func makeCertificateImageViewController() -> CertificateImageViewController {
        appFactory.makeCertificateImageViewController()
    }

    func makeCertificateContentViewController() -> CertificateContentViewController {
        appFactory.makeCertificateContentViewController()
    }

    func makeTodoWriteViewController() -> TodoWriteViewController {
        appFactory.makeTodoWriteViewController()
    }

    func makePopupViewController() -> PopupViewController {
        appFactory.makePopupViewController()
    }

    func makeModalityViewController() -> ModalityViewController {
        appFactory.makeModalityViewController()
    }

    func makeErrorViewController() -> ErrorViewController {
        appFactory.makeErrorViewController()
    }
}
