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
    func setRefreshAction(_ action: (() -> Void)?) {
        refreshAction = action
    }

    func handlePendingInviteDeepLink() {
        guard !isCurrentViewController(
            SplashViewController.self,
            UpdateViewController.self,
            OnboardingViewController.self
        ) else { return }

        guard let code = DeepLinkManager.shared.consumeInviteCode() else { return }

        pushGroupJoin(datas: GroupJoinViewDatas(code: code))
    }

    func popViewController(animated: Bool = true) {
        clearRefreshAction()

        navigationController.popViewController(animated: animated)
    }

    func popViewControllers(num: Int = 1, animated: Bool = true) {
        let currentIndex = navigationController.viewControllers.count - 1
        if currentIndex - num < 0 { return }

        let targetViewController = navigationController.viewControllers[currentIndex - num]

        clearRefreshAction()

        navigationController.popToViewController(targetViewController, animated: animated)
    }
}

extension NavigationCoordinator {
    func setSplash(animated: Bool = true) {
        setNavigationController(makeSplashViewController(), animated: animated)
    }

    func setOnboarding(animated: Bool = true) {
        setNavigationController(makeOnboardingViewController(), animated: animated)
    }

    func setStart(animated: Bool = true) {
        setNavigationController(makeStartViewController(), animated: animated)
    }

    func setMain(animated: Bool = true) {
        setNavigationController(makeMainViewController(), animated: animated)
    }

    func setUpdate(animated: Bool = true) {
        setNavigationController(makeUpdateViewController(), animated: animated)
    }

    func setComplete(datas: CompleteViewDatas? = nil, animated: Bool = true) {
        setNavigationController(makeCompleteViewController(), datas: datas, animated: animated)
    }

    func pushGroupJoin(datas: GroupJoinViewDatas? = nil, animated: Bool = true) {
        pushViewController(makeGroupJoinViewController(), datas: datas, animated: animated)
    }

    func pushGroupCreate(animated: Bool = true) {
        pushViewController(makeGroupCreateViewController(), animated: animated)
    }

    func pushMyPage(animated: Bool = true) {
        pushViewController(makeMyPageViewController(), animated: animated)
    }

    func pushStats(animated: Bool = true) {
        pushViewController(makeStatsViewController(), animated: animated)
    }

    func pushCertificationList(animated: Bool = true) {
        pushViewController(makeCertificationListViewController(), animated: animated)
    }

    func pushGroupManagement(animated: Bool = true) {
        pushViewController(makeGroupManagementViewController(), animated: animated)
    }

    func pushSetting(animated: Bool = true) {
        pushViewController(makeSettingViewController(), animated: animated)
    }

    func pushRanking(datas: RankingViewDatas? = nil, animated: Bool = true) {
        pushViewController(makeRankingViewController(), datas: datas, animated: animated)
    }

    func pushStart(datas: StartViewDatas? = nil, animated: Bool = true) {
        pushViewController(makeStartViewController(), datas: datas, animated: animated)
    }

    func pushTodoWrite(datas: TodoWriteViewDatas? = nil, animated: Bool = true) {
        pushViewController(makeTodoWriteViewController(), datas: datas, animated: animated)
    }

    func pushCertificateImage(datas: CertificateViewDatas? = nil, animated: Bool = true) {
        pushViewController(makeCertificateImageViewController(), datas: datas, animated: animated)
    }

    func pushCertificateContent(datas: CertificateViewDatas? = nil, animated: Bool = true) {
        pushViewController(makeCertificateContentViewController(), datas: datas, animated: animated)
    }

    func pushCertification(datas: CertificationViewDatas? = nil, animated: Bool = true) {
        pushViewController(makeCertificationViewController(), datas: datas, animated: animated)
    }
}

extension NavigationCoordinator {
    func showPopup(
        type: PopupTypes,
        alertType: AlertTypes? = nil,
        animated: Bool = true,
        completion: ((Any) -> Void)? = nil
    ) {
        let popupViewController = makePopupViewController()

        switch type {
        case .alert:
            popupViewController.datas = AlertPopupViewDatas(type: alertType)

        case .examinate:
            popupViewController.datas = ExaminatePopupViewDatas()
        }

        popupViewController.coordinator = self
        popupViewController.completion = completion
        popupViewController.modalPresentationStyle = .overFullScreen
        popupViewController.modalTransitionStyle = .crossDissolve

        lastViewController?.present(popupViewController, animated: animated)
    }

    func hidePopup(animated: Bool = true) {
        lastViewController?.dismiss(animated: animated)
    }
}

extension NavigationCoordinator {
    func showModal(reviews: [ReviewEntity]) {
        if let modalityWindow {
            if let viewController = modalityWindow.rootViewController as? ModalityViewController {
                viewController.updateReviewsAction(reviews: reviews)
            }
        } else {
            guard let windowScene = presentationWindowScene else { return }

            let window = UIWindow(windowScene: windowScene)
            let modalityViewController = makeModalityViewController()

            modalityViewController.coordinator = self
            modalityViewController.datas = ExaminateViewDatas(reviews: reviews)
            window.frame = UIScreen.main.bounds
            window.rootViewController = modalityViewController
            window.windowLevel = .alert + 1
            window.makeKeyAndVisible()

            modalityWindow = window
        }
    }

    func hideModal() {
        modalityWindow?.isHidden = true
        modalityWindow = nil
    }
}

extension NavigationCoordinator {
    func showErrorView(completion: @escaping () -> Void) {
        if let errorViewController = navigationController.presentedViewController as? ErrorViewController {
            errorViewController.completions.append(completion)
        } else {
            let errorViewController = makeErrorViewController()

            errorViewController.coordinator = self
            errorViewController.completions.append(completion)
            errorViewController.modalPresentationStyle = .overFullScreen
            errorViewController.modalTransitionStyle = .crossDissolve

            navigationController.present(errorViewController, animated: true)
        }
    }

    func dismissErrorView(completion: @escaping () -> Void) {
        setRefreshAction(nil)

        navigationController.presentedViewController?.dismiss(animated: true) { completion() }
    }
}

private extension NavigationCoordinator {
    var presentationWindowScene: UIWindowScene? {
        if let windowScene = navigationController.view.window?.windowScene {
            return windowScene
        }

        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }

    func isCurrentViewController(_ types: UIViewController.Type...) -> Bool {
        guard let currentViewController = navigationController.viewControllers.last else { return false }

        return types.contains { currentViewController.isKind(of: $0) }
    }

    func setNavigationController(
        _ viewControllers: BaseViewController...,
        datas: (any BaseEntity)? = nil,
        animated: Bool = true
    ) {
        if viewControllers.isEmpty { return }

        viewControllers.forEach { $0.coordinator = self }
        viewControllers.last?.datas = datas
        clearRefreshAction()

        navigationController.setViewControllers(viewControllers, animated: animated)
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    func pushViewController(_ viewController: BaseViewController, datas: (any BaseEntity)? = nil, animated: Bool = true) {
        if let currentViewController = navigationController.viewControllers.last as? BaseViewController,
           let datas, type(of: viewController) == type(of: currentViewController) {
            currentViewController.pages?.forEach { $0.updateView(datas) }
            return
        }

        viewController.coordinator = self
        viewController.datas = datas
        clearRefreshAction()

        navigationController.pushViewController(viewController, animated: animated)
    }

    func clearRefreshAction() {
        refreshAction = nil
    }

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
