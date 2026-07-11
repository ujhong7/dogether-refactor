//
//  PopupPage.swift
//  dogether
//
//  Created by seungyooooong on 12/7/25.
//

import Foundation

import RxRelay
import RxSwift

final class PopupPage: BasePage {
    let hideTapped = PublishRelay<Void>()
    let completeTapped = PublishRelay<Void>()
    let keyboardHeightChanged = PublishRelay<CGFloat>()
    let feedbackChanged = PublishRelay<String>()
    
    private let alertStackView = AlertStackView()
    private let examinateStackView = ExaminateStackView()
    private let disposeBag = DisposeBag()
    
    override func configureView() {
        backgroundColor = .grey700
        layer.cornerRadius = 12
    }
    
    override func configureAction() {
        addTapAction { _ in return }

        alertStackView.hideTapped
            .bind(to: hideTapped)
            .disposed(by: disposeBag)

        alertStackView.completeTapped
            .bind(to: completeTapped)
            .disposed(by: disposeBag)

        examinateStackView.hideTapped
            .bind(to: hideTapped)
            .disposed(by: disposeBag)

        examinateStackView.completeTapped
            .bind(to: completeTapped)
            .disposed(by: disposeBag)

        examinateStackView.keyboardHeightChanged
            .bind(to: keyboardHeightChanged)
            .disposed(by: disposeBag)

        examinateStackView.feedbackChanged
            .bind(to: feedbackChanged)
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [alertStackView, examinateStackView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        [alertStackView, examinateStackView].forEach { stackView in
            stackView.snp.makeConstraints {
                $0.verticalEdges.equalToSuperview().inset(24)
                $0.horizontalEdges.equalToSuperview().inset(20)
            }
        }
    }
    
    // MARK: - updateView
    func updateAlertPopup(_ datas: AlertPopupViewDatas) {
        if subviews.contains(examinateStackView) {
            examinateStackView.removeFromSuperview()
        }

        alertStackView.updateView(datas)
    }

    func updateExaminatePopup(_ datas: ExaminatePopupViewDatas) {
        if subviews.contains(alertStackView) {
            alertStackView.removeFromSuperview()
        }

        examinateStackView.updateView(datas)
    }

    func updateExaminateText(_ datas: DogetherTextViewDatas) {
        examinateStackView.updateView(datas)

        if datas.isShowKeyboard {
            addTapAction { [weak self] _ in
                guard let self else { return }
                examinateStackView.endEditing(true)
            }
        } else { addTapAction { _ in return } }
    }

    func updateRegisterButton(_ datas: DogetherButtonViewDatas) {
        examinateStackView.updateView(datas)
    }

    override func updateView(_ data: (any BaseEntity)?) {
        if let datas = data as? AlertPopupViewDatas {
            updateAlertPopup(datas)
        }
        
        if let datas = data as? ExaminatePopupViewDatas {
            updateExaminatePopup(datas)
        }
        
        if let datas = data as? DogetherTextViewDatas {
            updateExaminateText(datas)
        }
        
        if let datas = data as? DogetherButtonViewDatas {
            updateRegisterButton(datas)
        }
    }
}
