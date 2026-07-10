//
//  PopupViewModel.swift
//  dogether
//
//  Created by seungyooooong on 2/19/25.
//

import UIKit

import RxCocoa
import RxRelay

@MainActor
final class PopupViewModel {
    struct Output {
        let alertPopupViewDatas: Driver<AlertPopupViewDatas?>
        let examinatePopupViewDatas: Driver<ExaminatePopupViewDatas?>
        let examinateTextViewDatas: Driver<DogetherTextViewDatas>
        let registerButtonViewDatas: Driver<DogetherButtonViewDatas>
    }

    private let alertPopupViewDatas = BehaviorRelay<AlertPopupViewDatas?>(value: nil)
    private let examinatePopupViewDatas = BehaviorRelay<ExaminatePopupViewDatas?>(value: nil)
    private let examinateTextViewDatas = BehaviorRelay<DogetherTextViewDatas>(value: DogetherTextViewDatas())
    private let registerButtonViewDatas = BehaviorRelay<DogetherButtonViewDatas>(
        value: DogetherButtonViewDatas(status: .disabled)
    )

    var feedback: String? { examinatePopupViewDatas.value?.feedback }

    var output: Output {
        Output(
            alertPopupViewDatas: alertPopupViewDatas.asDriver(),
            examinatePopupViewDatas: examinatePopupViewDatas.asDriver(),
            examinateTextViewDatas: examinateTextViewDatas.asDriver(),
            registerButtonViewDatas: registerButtonViewDatas.asDriver()
        )
    }

    func setDatas(_ datas: AlertPopupViewDatas) {
        alertPopupViewDatas.accept(datas)
    }

    func setDatas(_ datas: ExaminatePopupViewDatas) {
        examinatePopupViewDatas.accept(datas)
    }
}

extension PopupViewModel {
    func updateIsFirstResponder(isFirstResponder: Bool) {
        examinatePopupViewDatas.update { $0?.isFirstResponder = isFirstResponder }
        examinateTextViewDatas.update { $0.isShowKeyboard = isFirstResponder }
    }
    
    func updateFeedback(feedback: String) {
        examinatePopupViewDatas.update { $0?.feedback = feedback }
        examinateTextViewDatas.update { $0.text = feedback }
        registerButtonViewDatas.update { $0.status = feedback.count > 0 ? .enabled : .disabled }
    }
}
