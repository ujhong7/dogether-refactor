//
//  BaseViewController.swift
//  dogether
//
//  Created by 박지은 on 2/9/25.
//

import UIKit

import RxCocoa
import RxSwift

class BaseViewController: UIViewController, CoordinatorDelegate {
    weak var coordinator: (any NavigationCoordinating)?
    var datas: (any BaseEntity)?
    var pages: Array<BasePage>?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .grey900
        
        guard let pages else { return }
        configurePages(pages)
        
        setViewDatas()
    }
    
    /// UI를 구성할 페이지들을 설정하는 역할을 합니다
    func configurePages(_ pages: [BasePage]) {
        pages.forEach { page in
            page.coordinatorDelegate = self
            page.frame = view.frame
            
            view.addSubview(page)
            page.snp.makeConstraints {
                $0.edges.equalTo(view.safeAreaLayoutGuide)
            }
            
            page.pageDidLoad()
        }
    }
    
    /// View를 구성하는 필수 데이터를 세팅하고 바인딩하는 역할을 합니다
    func setViewDatas() { }
    
    /// Output의 변화에 Page가 update 되도록 바인딩하는 역할을 합니다
    func bind<Entity: BaseEntity>(_ output: Driver<Entity>) {
        output
            .distinctUntilChanged()
            .drive(onNext: { [weak self] datas in
                guard let self, let pages else { return }
                pages.forEach { $0.updateView(datas) }
            })
            .disposed(by: disposeBag)
    }

    func bind<Entity: BaseEntity>(_ output: Driver<Entity?>) {
        output
            .distinctUntilChanged()
            .drive(onNext: { [weak self] datas in
                guard let self, let pages, let datas else { return }
                pages.forEach { $0.updateView(datas) }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - async task
extension BaseViewController {
    func runTask<Value>(
        showLoading: Bool = true,
        retryOnCommonNetworkError: Bool = true,
        onAlertComplete: ((AlertTypes) -> Void)? = nil,
        operation: @escaping () async throws -> Value,
        success: ((Value) -> Void)? = nil,
        catch errorHandler: ((Error) -> Void)? = nil
    ) {
        Task { [weak self] in
            guard let self else { return }
            await executeTask(
                showLoading: showLoading,
                retryOnCommonNetworkError: retryOnCommonNetworkError,
                onAlertComplete: onAlertComplete,
                operation: operation,
                success: success,
                catch: errorHandler
            )
        }
    }

    private func executeTask<Value>(
        showLoading: Bool,
        retryOnCommonNetworkError: Bool,
        onAlertComplete: ((AlertTypes) -> Void)?,
        operation: @escaping () async throws -> Value,
        success: ((Value) -> Void)?,
        catch errorHandler: ((Error) -> Void)?
    ) async {
        while true {
            if showLoading { LoadingManager.shared.showLoading() }

            do {
                let value = try await operation()
                if showLoading { LoadingManager.shared.hideLoading() }
                success?(value)
                return
            } catch {
                if showLoading { LoadingManager.shared.hideLoading() }

                switch AppErrorAction.resolve(for: error) {
                case .retry where retryOnCommonNetworkError:
                    guard await waitForRetry() else {
                        errorHandler?(error)
                        return
                    }
                    continue

                case .retry, .passThrough:
                    errorHandler?(error)
                    return

                case .logout:
                    showLogoutPopup()
                    return

                case .alert(let alertType):
                    showAlertPopup(alertType, completion: onAlertComplete)
                    return
                }
            }
        }
    }

    private func waitForRetry() async -> Bool {
        guard let coordinator else { return false }

        await withCheckedContinuation { continuation in
            coordinator.showErrorView {
                continuation.resume()
            }
        }

        return true
    }

    private func showLogoutPopup() {
        coordinator?.showPopup(type: .alert, alertType: .needLogout) { [weak self] _ in
            guard let self else { return }
            UserDefaultsManager.logout()
            guard let coordinator else { return }
            coordinator.setOnboarding()
        }
    }

    private func showAlertPopup(_ alertType: AlertTypes, completion: ((AlertTypes) -> Void)?) {
        coordinator?.showPopup(type: .alert, alertType: alertType) { _ in
            completion?(alertType)
        }
    }
}
