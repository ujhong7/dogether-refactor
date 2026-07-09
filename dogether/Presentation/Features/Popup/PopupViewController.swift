//
//  PopupViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/15/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class PopupViewController: BaseViewController {
    private let popupPage = PopupPage()
    private let viewModel = PopupViewModel()
    private let disposeBag = DisposeBag()
    
    // FIXME: 추후 수정
    var completion: ((Any) -> Void)?
    
    override func viewDidLoad() {
        pages = [popupPage]
        
        super.viewDidLoad()
        
        onAppear()
        bindActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.updateIsFirstResponder(isFirstResponder: true)
    }
    
    override func setViewDatas() {
        let output = viewModel.output

        if let datas = datas as? AlertPopupViewDatas {
            viewModel.setDatas(datas)
            bind(output.alertPopupViewDatas)
        }
        
        if let datas = datas as? ExaminatePopupViewDatas {
            viewModel.setDatas(datas)
            bind(output.examinatePopupViewDatas)
            bind(output.examinateTextViewDatas)
            bind(output.registerButtonViewDatas)
        }
    }
}

extension PopupViewController {
    private func onAppear() {
        // MARK: - setup for popup ui
        // FIXME: 추후 수정
        view.backgroundColor = .grey900.withAlphaComponent(0.8)
        view.addTapAction { [weak self] _ in
            guard let self else { return }
            hidePopup()
        }
        pages?.forEach { page in
            page.snp.remakeConstraints {
                $0.centerX.equalTo(view)
                $0.centerY.equalTo(view)
                $0.horizontalEdges.equalTo(view).inset(16)
            }
        }
    }

    private func bindActions() {
        popupPage.hideTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.hidePopup()
            })
            .disposed(by: disposeBag)

        popupPage.completeTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.hidePopup()
                self?.completeAction()
            })
            .disposed(by: disposeBag)

        popupPage.keyboardHeightChanged
            .asSignal()
            .emit(onNext: { [weak self] height in
                self?.updateKeyboardHeight(height: height)
            })
            .disposed(by: disposeBag)

        popupPage.feedbackChanged
            .asSignal()
            .emit(onNext: { [weak self] feedback in
                self?.viewModel.updateFeedback(feedback: feedback)
            })
            .disposed(by: disposeBag)
    }

    private func completeAction() {
        let param: Any = viewModel.feedback as Any
        completion?(param)
    }
    
    private func hidePopup() {
        coordinator?.hidePopup()
    }
    
    private func updateKeyboardHeight(height: CGFloat) {
        let safeAreaTop = view.safeAreaInsets.top
        let safeAreaHeight = view.frame.height - height - safeAreaTop
        let newCenterY = safeAreaTop + safeAreaHeight / 2
        
        pages?.forEach { page in
            page.snp.updateConstraints {
                $0.centerY.equalTo(view).offset(newCenterY - view.bounds.midY)
            }
        }
        
        UIView.animate(withDuration: 0.35) { [weak self] in
            guard let self else { return }
            view.layoutIfNeeded()
        }
        
        viewModel.updateIsFirstResponder(isFirstResponder: height > 0)
    }
}
