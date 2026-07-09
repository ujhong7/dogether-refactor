//
//  NavigationCoordinator+Popup.swift
//  dogether
//
//  Created by yujaehong on 7/7/26.
//

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
