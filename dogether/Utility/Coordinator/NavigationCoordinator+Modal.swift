//
//  NavigationCoordinator+Modal.swift
//  dogether
//
//  Created by yujaehong on 7/7/26.
//

import UIKit

extension NavigationCoordinator {
    func showModal(reviews: [ReviewEntity]) {
        if let modalityWindow {
            if let viewController = modalityWindow.rootViewController as? ModalityViewController {
                viewController.updateReviewsAction(reviews: reviews)
            }
        } else {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

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
