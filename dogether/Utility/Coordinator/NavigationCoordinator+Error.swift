//
//  NavigationCoordinator+Error.swift
//  dogether
//
//  Created by yujaehong on 7/7/26.
//

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
