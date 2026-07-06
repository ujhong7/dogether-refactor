//
//  BaseViewController.swift
//  dogether
//
//  Created by 박지은 on 2/9/25.
//

import UIKit

import RxSwift
import RxCocoa

class BaseViewController: UIViewController, CoordinatorDelegate {
    weak var coordinator: NavigationCoordinator?
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
    
    /// ViewDatas의 변화에 Page가 update 되도록 바인딩하는 역할을 합니다
    func bind<Entity: BaseEntity>(_ relay: BehaviorRelay<Entity>) {
        relay
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: relay.value)
            .drive(onNext: { [weak self] datas in
                guard let self, let pages else { return }
                pages.forEach { $0.updateView(datas) }
            })
            .disposed(by: disposeBag)
    }
    // FIXME: 추후 병합
    func bind<Entity: BaseEntity>(_ relay: BehaviorRelay<Entity?>) {
        relay
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: relay.value)
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
        operation: @escaping () async throws -> Value,
        success: ((Value) -> Void)? = nil,
        catch errorHandler: ((Error) -> Void)? = nil
    ) {
        Task { [weak self] in
            guard let self else { return }
            await executeTask(
                showLoading: showLoading,
                retryOnCommonNetworkError: retryOnCommonNetworkError,
                operation: operation,
                success: success,
                catch: errorHandler
            )
        }
    }

    private func executeTask<Value>(
        showLoading: Bool,
        retryOnCommonNetworkError: Bool,
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

                if retryOnCommonNetworkError, isCommonNetworkError(error) {
                    guard await waitForRetry() else {
                        errorHandler?(error)
                        return
                    }
                    continue
                }

                if handleNetworkError(error) { return }

                errorHandler?(error)
                return
            }
        }
    }

    private func isCommonNetworkError(_ error: Error) -> Bool {
        if error is URLError || error is DecodingError { return true }

        guard let error = error as? NetworkError else { return false }
        guard case let .dogetherError(code, _) = error else { return true }

        return !(code == .ATF0002 || code == .ATF0003 ||
                 code == .CGF0002 || code == .CGF0003 || code == .CGF0004 || code == .CGF0005)
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

    private func handleNetworkError(_ error: Error) -> Bool {
        guard let error = error as? NetworkError,
              case let .dogetherError(code, _) = error,
              code == .ATF0003 else { return false }

        coordinator?.showPopup(type: .alert, alertType: .needLogout) { [weak self] _ in
            guard let self else { return }
            UserDefaultsManager.logout()
            coordinator?.setNavigationController(OnboardingViewController())
        }

        return true
    }
}
