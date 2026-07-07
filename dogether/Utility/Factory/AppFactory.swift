//
//  AppFactory.swift
//  dogether
//
//  Created by yujaehong on 7/6/26.
//

import UIKit

@MainActor
final class AppFactory {
    enum BuildMode {
        case debug
        case live
    }

    private let buildMode: BuildMode

    init(buildMode: BuildMode = .live) {
        self.buildMode = buildMode
    }
}

// MARK: - Repository
private extension AppFactory {
    func makeAppInfoRepository() -> AppInfoProtocol {
        switch buildMode {
        case .debug:
            return AppInfoRepositoryTest()
        case .live:
            return AppInfoRepository()
        }
    }

    func makeAuthRepository() -> AuthProtocol {
        switch buildMode {
        case .debug:
            return AuthRepositoryTest()
        case .live:
            return AuthRepository()
        }
    }

    func makeGroupRepository() -> GroupProtocol {
        switch buildMode {
        case .debug:
            return GroupRepositoryTest()
        case .live:
            return GroupRepository()
        }
    }

    func makeChallengeGroupsRepository() -> ChallengeGroupsProtocol {
        switch buildMode {
        case .debug:
            return ChallengeGroupsRepositoryTest()
        case .live:
            return ChallengeGroupsRepository()
        }
    }

    func makeTodoCertificationsRepository() -> TodoCertificationsProtocol {
        switch buildMode {
        case .debug:
            return TodoCertificationsRepositoryTest()
        case .live:
            return TodoCertificationsRepository()
        }
    }

    func makeUserRepository() -> UserProtocol {
        switch buildMode {
        case .debug:
            return UserRepositoryTest()
        case .live:
            return UserRepository()
        }
    }
}

// MARK: - UseCase
private extension AppFactory {
    func makeAppLaunchUseCase() -> AppLaunchUseCase {
        AppLaunchUseCase(repository: makeAppInfoRepository())
    }

    func makeAuthUseCase() -> AuthUseCase {
        AuthUseCase(repository: makeAuthRepository())
    }

    func makeChallengeGroupUseCase() -> ChallengeGroupUseCase {
        ChallengeGroupUseCase(repository: makeChallengeGroupsRepository())
    }

    func makeGroupUseCase() -> GroupUseCase {
        GroupUseCase(repository: makeGroupRepository())
    }

    func makeTodoCertificationsUseCase() -> TodoCertificationsUseCase {
        TodoCertificationsUseCase(repository: makeTodoCertificationsRepository())
    }

    func makeUserUseCase() -> UserUseCase {
        UserUseCase(repository: makeUserRepository())
    }
}

// MARK: - ViewController
extension AppFactory {
    func makeNavigationCoordinator(navigationController: UINavigationController) -> NavigationCoordinator {
        NavigationCoordinator(
            navigationController: navigationController,
            appFactory: self,
            todoCertificationsUseCase: makeTodoCertificationsUseCase()
        )
    }

    func makeSplashViewController() -> SplashViewController {
        SplashViewController(
            viewModel: SplashViewModel(
                appLaunchUseCase: makeAppLaunchUseCase(),
                groupUseCase: makeGroupUseCase()
            )
        )
    }

    func makeOnboardingViewController() -> OnboardingViewController {
        OnboardingViewController(
            viewModel: OnboardingViewModel(
                authUseCase: makeAuthUseCase(),
                groupUseCase: makeGroupUseCase()
            )
        )
    }

    func makeMainViewController() -> MainViewController {
        MainViewController(
            viewModel: MainViewModel(
                groupUseCase: makeGroupUseCase(),
                challengeGroupsUseCase: makeChallengeGroupUseCase(),
                todoCertificationsUseCase: makeTodoCertificationsUseCase()
            )
        )
    }

    func makeGroupJoinViewController() -> GroupJoinViewController {
        GroupJoinViewController(viewModel: GroupJoinViewModel(groupUseCase: makeGroupUseCase()))
    }

    func makeGroupCreateViewController() -> GroupCreateViewController {
        GroupCreateViewController(viewModel: GroupCreateViewModel(groupUseCase: makeGroupUseCase()))
    }

    func makeRankingViewController() -> RankingViewController {
        RankingViewController(
            viewModel: RankingViewModel(
                groupUseCase: makeGroupUseCase(),
                challengeGroupsUseCase: makeChallengeGroupUseCase()
            )
        )
    }

    func makeCertificationViewController() -> CertificationViewController {
        CertificationViewController(
            viewModel: CertificationViewModel(challengeGroupsUseCase: makeChallengeGroupUseCase())
        )
    }

    func makeCertificateImageViewController() -> CertificateImageViewController {
        CertificateImageViewController(
            viewModel: CertificateViewModel(challengeGroupUseCase: makeChallengeGroupUseCase())
        )
    }

    func makeCertificateContentViewController() -> CertificateContentViewController {
        CertificateContentViewController(
            viewModel: CertificateViewModel(challengeGroupUseCase: makeChallengeGroupUseCase())
        )
    }

    func makeCertificationListViewController() -> CertificationListViewController {
        CertificationListViewController(viewModel: CertificationListViewModel(userUseCase: makeUserUseCase()))
    }

    func makeStatsViewController() -> StatsViewController {
        StatsViewController(
            viewModel: StatsViewModel(
                userUseCase: makeUserUseCase(),
                groupUseCase: makeGroupUseCase()
            )
        )
    }

    func makeMyPageViewController() -> MyPageViewController {
        MyPageViewController(viewModel: MyPageViewModel(userUseCase: makeUserUseCase()))
    }

    func makeSettingViewController() -> SettingViewController {
        SettingViewController(viewModel: SettingViewModel(authUseCase: makeAuthUseCase()))
    }

    func makeGroupManagementViewController() -> GroupManagementViewController {
        GroupManagementViewController(
            viewModel: GroupManagementViewModel(
                groupUseCase: makeGroupUseCase()
            )
        )
    }

    func makeTodoWriteViewController() -> TodoWriteViewController {
        TodoWriteViewController(
            viewModel: TodoWriteViewModel(challengeGroupsUseCase: makeChallengeGroupUseCase())
        )
    }

    func makeModalityViewController() -> ModalityViewController {
        ModalityViewController(
            viewModel: ModalityViewModel(todoCertificationsUseCase: makeTodoCertificationsUseCase())
        )
    }

    func makeStartViewController() -> StartViewController {
        StartViewController()
    }

    func makeCompleteViewController() -> CompleteViewController {
        CompleteViewController()
    }

    func makeUpdateViewController() -> UpdateViewController {
        UpdateViewController()
    }

    func makePopupViewController() -> PopupViewController {
        PopupViewController()
    }

    func makeErrorViewController() -> ErrorViewController {
        ErrorViewController()
    }
}
