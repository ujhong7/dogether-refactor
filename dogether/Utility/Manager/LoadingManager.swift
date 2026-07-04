//
//  LoadingManager.swift
//  dogether
//
//  Created by seungyooooong on 5/19/25.
//

import UIKit

@MainActor
final class LoadingManager {
    static let shared = LoadingManager()
    
    private var loadingWindow: UIWindow?
    private var loadingCount: Int = 0
    
    private init() { }
    
    func showLoading() {
        loadingCount += 1

        guard loadingWindow == nil,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let loadingViewController = LoadingViewController()

        window.frame = UIScreen.main.bounds
        window.rootViewController = loadingViewController
        window.windowLevel = .alert + 99
        window.makeKeyAndVisible()

        loadingWindow = window
    }

    func hideLoading() {
        loadingCount = max(loadingCount - 1, 0)

        if loadingCount == 0 {
            loadingWindow?.isHidden = true
            loadingWindow = nil
        }
    }
}
