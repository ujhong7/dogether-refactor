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
    private let viewModel = ModalityViewModel()
    
    override func viewDidLoad() {
        examinatePage.delegate = self
        
        pages = [examinatePage]

        super.viewDidLoad()
    }
    
    override func setViewDatas() {
        if let datas = datas as? ExaminateViewDatas {
            self.viewModel.examinateViewDatas.accept(datas)
        }
        
        bind(self.viewModel.examinateViewDatas)
        bind(self.viewModel.examinateButtonViewDatas)
    }
}

protocol ExaminateDelegate {
    func updateReviewsAction(reviews: [ReviewEntity])
    func examinateAction(type: FilterTypes)
    func sendAction()
}

extension ModalityViewController: ExaminateDelegate {
    func updateReviewsAction(reviews: [ReviewEntity]) {
        self.viewModel.setReviews(reviews: reviews)
    }
    
    func examinateAction(type: FilterTypes) {
        self.viewModel.setResult(result: type.reviewResult)
        self.viewModel.setFeedback()
        self.viewModel.setButtonStatus(status: type == .approve ? .enabled : .disabled)

        self.coordinator?.showPopup(type: .examinate) { [weak self] reviewFeedback in
            guard let self, let reviewFeedback = reviewFeedback as? String else { return }
            self.viewModel.setFeedback(feedback: reviewFeedback)
            self.viewModel.setButtonStatus(status: .enabled)
        }
    }
    
    func sendAction() {
        runTask { [weak self] in
            guard let self else { return }
            try await self.viewModel.reviewTodo()
            if self.viewModel.examinateViewDatas.value.reviews.count == self.viewModel.examinateViewDatas.value.index + 1 {
                self.coordinator?.hideModal()
            } else {
                self.viewModel.setIndex(direction: .next)
                self.viewModel.setResult()
                self.viewModel.setFeedback()
                self.viewModel.setButtonStatus(status: .disabled)
            }
        }
    }
}
