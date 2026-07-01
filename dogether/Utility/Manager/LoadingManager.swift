//
//  LoadingManager.swift
//  dogether
//
//  Created by seungyooooong on 5/19/25.
//

import UIKit

final class LoadingManager {
    static let shared = LoadingManager()
    
    private var loadingWindow: UIWindow?
    private var loadingCount: Int = 0
    
    private init() { }
    
    // MARK: loadingCount / loadingWindow는 항상 메인 액터에서만 접근하여 데이터 레이스를 방지합니다
    func showLoading() {
        Task { @MainActor [weak self] in
            guard let self else { return }
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
    }

    func hideLoading() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            loadingCount -= 1

            if loadingCount <= 0 {
                loadingWindow?.isHidden = true
                loadingWindow = nil
            }
        }
    }
}
