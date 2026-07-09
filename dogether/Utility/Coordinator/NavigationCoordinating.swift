//
//  NavigationCoordinating.swift
//  dogether
//
//  Created by yujaehong on 7/9/26.
//

import UIKit

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
