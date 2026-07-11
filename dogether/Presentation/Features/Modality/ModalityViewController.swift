//
//  ModalityViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/17/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class ModalityViewController: BaseViewController {
    private let examinatePage = ExaminatePage()
    private let viewModel: ModalityViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: ModalityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [examinatePage]

        super.viewDidLoad()

        bindActions()
    }
    
    override func setViewDatas() {
        if let datas = datas as? ExaminateViewDatas {
            viewModel.setDatas(datas)
        }
        
        let output = viewModel.output
        bind(output.examinateViewDatas, update: examinatePage.updateView)
        bind(output.examinateButtonViewDatas, update: examinatePage.updateView)
    }

    func updateReviews(_ reviews: [ReviewEntity]) {
        viewModel.setReviews(reviews: reviews)
    }
}

extension ModalityViewController {
    private func bindActions() {
        examinatePage.examinateSelected
            .asSignal()
            .emit(onNext: { [weak self] type in
                self?.examinate(type: type)
            })
            .disposed(by: disposeBag)

        examinatePage.sendTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.send()
            })
            .disposed(by: disposeBag)
    }

    private func examinate(type: FilterTypes) {
        viewModel.setResult(result: type.reviewResult)
        viewModel.setFeedback()
        viewModel.setButtonStatus(status: type == .approve ? .enabled : .disabled)

        coordinator?.showPopup(type: .examinate) { [weak self] reviewFeedback in
            guard let self, let reviewFeedback = reviewFeedback as? String else { return }
            viewModel.setFeedback(feedback: reviewFeedback)
            viewModel.setButtonStatus(status: .enabled)
        }
    }

    private func send() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.reviewTodo()
            if viewModel.isLastReview {
                coordinator?.hideModal()
            } else {
                viewModel.setIndex(direction: .next)
                viewModel.setResult()
                viewModel.setFeedback()
                viewModel.setButtonStatus(status: .disabled)
            }
        }
    }
}
