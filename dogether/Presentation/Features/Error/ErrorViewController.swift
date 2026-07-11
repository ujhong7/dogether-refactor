//
//  ErrorViewController.swift
//  dogether
//
//  Created by seungyooooong on 12/17/25.
//

import Foundation

import RxCocoa
import RxSwift

final class ErrorViewController: BaseViewController {
    private let errorPage = ErrorPage()
    private let viewModel = ErrorViewModel()
    private let disposeBag = DisposeBag()
    
    // FIXME: 추후 수정
    var completions: [(() -> Void)] = []
    
    override func viewDidLoad() {
        pages = [errorPage]

        super.viewDidLoad()
    }
    
    override func setViewDatas() {
        let output = viewModel.output
        bind(output.buttonViewDatas, update: errorPage.updateView)

        errorPage.retryTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.retry()
            })
            .disposed(by: disposeBag)
    }
}

extension ErrorViewController {
    private func retry() {
        coordinator?.dismissErrorView() { [weak self] in
            guard let self else { return }
            while let completion = completions.popLast() { completion() }
        }
    }
}
