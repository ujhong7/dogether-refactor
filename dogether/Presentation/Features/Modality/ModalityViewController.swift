//
//  ModalityViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/17/25.
//

import UIKit
import SnapKit

final class ModalityViewController: BaseViewController {
    private let examinatePage = ExaminatePage()
    private let viewModel: ModalityViewModel

    init(viewModel: ModalityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        examinatePage.delegate = self
        
        pages = [examinatePage]

        super.viewDidLoad()
    }
    
    override func setViewDatas() {
        if let datas = datas as? ExaminateViewDatas {
            viewModel.examinateViewDatas.accept(datas)
        }
        
        bind(viewModel.examinateViewDatas)
        bind(viewModel.examinateButtonViewDatas)
    }
}

@MainActor
protocol ExaminateDelegate {
    func updateReviewsAction(reviews: [ReviewEntity])
    func examinateAction(type: FilterTypes)
    func sendAction()
}

extension ModalityViewController: ExaminateDelegate {
    func updateReviewsAction(reviews: [ReviewEntity]) {
        viewModel.setReviews(reviews: reviews)
    }
    
    func examinateAction(type: FilterTypes) {
        viewModel.setResult(result: type.reviewResult)
        viewModel.setFeedback()
        viewModel.setButtonStatus(status: type == .approve ? .enabled : .disabled)

        coordinator?.showPopup(type: .examinate) { [weak self] reviewFeedback in
            guard let self, let reviewFeedback = reviewFeedback as? String else { return }
            viewModel.setFeedback(feedback: reviewFeedback)
            viewModel.setButtonStatus(status: .enabled)
        }
    }
    
    func sendAction() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.reviewTodo()
            if viewModel.examinateViewDatas.value.reviews.count == viewModel.examinateViewDatas.value.index + 1 {
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
