//
//  NavigationCoordinator.swift
//  dogether
//
//  Created by seungyooooong on 3/21/25.
//

import UIKit

// MARK: AnyObject를 채택해 '클래스 전용' 프로토콜로 만들어 줌
@MainActor
protocol CoordinatorDelegate: AnyObject {
    var coordinator: (any NavigationCoordinating)? { get set }
}

@MainActor
protocol NavigationCoordinating: AnyObject {
    func setRefreshAction(_ action: (() -> Void)?)
    func checkCurrentViewController(_ types: UIViewController.Type...) -> Bool

    func popViewController(animated: Bool)
    func popViewControllers(num: Int, animated: Bool)

    func setSplash(animated: Bool)
    func setOnboarding(animated: Bool)
    func setStart(animated: Bool)
    func setMain(animated: Bool)
    func setUpdate(animated: Bool)
    func setComplete(datas: CompleteViewDatas?, animated: Bool)

    func pushGroupJoin(datas: GroupJoinViewDatas?, animated: Bool)
    func pushGroupCreate(animated: Bool)
    func pushMyPage(animated: Bool)
    func pushStats(animated: Bool)
    func pushCertificationList(animated: Bool)
    func pushGroupManagement(animated: Bool)
    func pushSetting(animated: Bool)
    func pushRanking(datas: RankingViewDatas?, animated: Bool)
    func pushStart(datas: StartViewDatas?, animated: Bool)
    func pushTodoWrite(datas: TodoWriteViewDatas?, animated: Bool)
    func pushCertificateImage(datas: CertificateViewDatas?, animated: Bool)
    func pushCertificateContent(datas: CertificateViewDatas?, animated: Bool)
    func pushCertification(datas: CertificationViewDatas?, animated: Bool)

    func showPopup(
        type: PopupTypes,
        alertType: AlertTypes?,
        animated: Bool,
        completion: ((Any) -> Void)?
    )
    func hidePopup(animated: Bool)

    func showModal(reviews: [ReviewEntity])
    func hideModal()

    func showErrorView(completion: @escaping () -> Void)
    func dismissErrorView(completion: @escaping () -> Void)
}

extension NavigationCoordinating {
    func popViewController() {
        popViewController(animated: true)
    }

    func popViewControllers(num: Int) {
        popViewControllers(num: num, animated: true)
    }

    func setSplash() {
        setSplash(animated: true)
    }

    func setOnboarding() {
        setOnboarding(animated: true)
    }

    func setStart() {
        setStart(animated: true)
    }

    func setMain() {
        setMain(animated: true)
    }

    func setUpdate() {
        setUpdate(animated: true)
    }

    func setComplete(datas: CompleteViewDatas?) {
        setComplete(datas: datas, animated: true)
    }

    func pushGroupJoin(datas: GroupJoinViewDatas? = nil) {
        pushGroupJoin(datas: datas, animated: true)
    }

    func pushGroupCreate() {
        pushGroupCreate(animated: true)
    }

    func pushMyPage() {
        pushMyPage(animated: true)
    }

    func pushStats() {
        pushStats(animated: true)
    }

    func pushCertificationList() {
        pushCertificationList(animated: true)
    }

    func pushGroupManagement() {
        pushGroupManagement(animated: true)
    }

    func pushSetting() {
        pushSetting(animated: true)
    }

    func pushRanking(datas: RankingViewDatas?) {
        pushRanking(datas: datas, animated: true)
    }

    func pushStart(datas: StartViewDatas?) {
        pushStart(datas: datas, animated: true)
    }

    func pushTodoWrite(datas: TodoWriteViewDatas?) {
        pushTodoWrite(datas: datas, animated: true)
    }

    func pushCertificateImage(datas: CertificateViewDatas?) {
        pushCertificateImage(datas: datas, animated: true)
    }

    func pushCertificateContent(datas: CertificateViewDatas?) {
        pushCertificateContent(datas: datas, animated: true)
    }

    func pushCertification(datas: CertificationViewDatas?) {
        pushCertification(datas: datas, animated: true)
    }

    func showPopup(
        type: PopupTypes,
        alertType: AlertTypes? = nil,
        completion: ((Any) -> Void)? = nil
    ) {
        showPopup(type: type, alertType: alertType, animated: true, completion: completion)
    }

    func hidePopup() {
        hidePopup(animated: true)
    }
}

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
