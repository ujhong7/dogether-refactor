//
//  NavigationCoordinator+Navigation.swift
//  dogether
//
//  Created by yujaehong on 7/7/26.
//

import UIKit

extension NavigationCoordinator {
    func setRefreshAction(_ action: (() -> Void)?) {
        refreshAction = action
    }

    func checkCurrentViewController(_ types: UIViewController.Type...) -> Bool {
        guard let currentViewController = navigationController.viewControllers.last else { return false }

        return types.contains { currentViewController.isKind(of: $0) }
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

private extension NavigationCoordinator {
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
}
