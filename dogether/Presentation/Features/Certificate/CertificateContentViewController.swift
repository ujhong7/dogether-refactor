//
//  CertificateContentViewController.swift
//  dogether
//
//  Created by seungyooooong on 5/13/25.
//

import UIKit

import RxCocoa
import RxSwift

final class CertificateContentViewController: BaseViewController {
    private let certificateContentPage = CertificateContentPage()
    private let viewModel: CertificateViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: CertificateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [certificateContentPage]

        super.viewDidLoad()

        bindActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.updateIsFirstResponder(isFirstResponder: true)
    }
    
    override func setViewDatas() {
        if let datas = datas as? CertificateViewDatas {
            viewModel.setDatas(datas)
        }
        
        let output = viewModel.output
        bind(output.certificateViewDatas)
        bind(output.certificateTextViewDatas)
        bind(output.certificateButtonViewDatas)
    }
}

extension CertificateContentViewController {
    private func bindActions() {
        certificateContentPage.keyboardHeightChanged
            .asSignal()
            .emit(onNext: { [weak self] height in
                self?.updateKeyboardHeight(height)
            })
            .disposed(by: disposeBag)

        certificateContentPage.contentChanged
            .asSignal()
            .emit(onNext: { [weak self] content in
                self?.viewModel.updateContent(content: content)
            })
            .disposed(by: disposeBag)

        certificateContentPage.certifyTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.certifyTodo()
            })
            .disposed(by: disposeBag)
    }

    private func updateKeyboardHeight(_ height: CGFloat) {
        viewModel.updateKeyboardHeight(height: height)
        viewModel.updateIsFirstResponder(isFirstResponder: height > 0)
    }

    private func certifyTodo() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.certifyTodo()

            coordinator?.popViewControllers(num: 2)
        }
    }
}
