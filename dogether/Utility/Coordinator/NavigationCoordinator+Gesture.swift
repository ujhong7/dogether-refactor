//
//  NavigationCoordinator+Gesture.swift
//  dogether
//
//  Created by yujaehong on 7/7/26.
//

import UIKit

extension NavigationCoordinator: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController.viewControllers.count > 1
    }
}
