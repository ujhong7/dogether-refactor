//
//  NavigationCoordinator+Notification.swift
//  dogether
//
//  Created by yujaehong on 7/7/26.
//

import UIKit

extension NavigationCoordinator: NotificationHandler {
    func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let notificationTypeString = userInfo["type"] as? String,
              let notificationType = PushNoticeTypes(rawValue: notificationTypeString) else { return }

        switch notificationType {
        case .certification:
            handleCertificationNotification(userInfo: userInfo)

        case .review:
            refreshIfCurrentViewControllerIs(MainViewController.self, RankingViewController.self, StatsViewController.self)

        case .join:
            refreshIfCurrentViewControllerIs(
                MainViewController.self,
                RankingViewController.self,
                StatsViewController.self,
                GroupManagementViewController.self
            )
        }
    }

    @objc func updateLastAccessDate() {
        if UserDefaultsManager.shared.lastAccessDate != Date().toString() {
            UserDefaultsManager.shared.lastAccessDate = Date().toString()

            refreshAction?()
        }
    }
}

private extension NavigationCoordinator {
    func handleCertificationNotification(userInfo: [AnyHashable: Any]) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let reviews = try await todoCertificationsUseCase.getReviews()

                if reviews.isEmpty { return }
                await MainActor.run { self.showModal(reviews: reviews) }
            } catch {
                await handleNotificationError(error, userInfo: userInfo)
            }
        }
    }

    func refreshIfCurrentViewControllerIs(_ types: UIViewController.Type...) {
        guard let currentViewController = navigationController.viewControllers.last else { return }

        if types.contains(where: { currentViewController.isKind(of: $0) }) {
            refreshAction?()
        }
    }

    func handleNotificationError(_ error: Error, userInfo: [AnyHashable: Any]) async {
        switch AppErrorAction.resolve(for: error) {
        case .retry:
            showErrorView { [weak self] in
                self?.handleNotification(userInfo: userInfo)
            }
        case .logout:
            showLogoutPopup()
        case .alert, .passThrough:
            return
        }
    }

    func showLogoutPopup() {
        showPopup(type: .alert, alertType: .needLogout) { [weak self] _ in
            guard let self else { return }
            UserDefaultsManager.logout()
            setOnboarding()
        }
    }
}
