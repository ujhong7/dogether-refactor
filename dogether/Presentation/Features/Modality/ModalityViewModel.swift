//
//  ModalityViewModel.swift
//  dogether
//
//  Created by seungyooooong on 2/20/25.
//

import Foundation

import RxCocoa
import RxRelay

@MainActor
final class ModalityViewModel {
    struct Output {
        let examinateViewDatas: Driver<ExaminateViewDatas>
        let examinateButtonViewDatas: Driver<DogetherButtonViewDatas>
    }

    private let todoCertificationsUseCase: TodoCertificationsUseCase
    
    private let examinateViewDatas = BehaviorRelay<ExaminateViewDatas>(value: ExaminateViewDatas())
    private let examinateButtonViewDatas = BehaviorRelay<DogetherButtonViewDatas>(
        value: DogetherButtonViewDatas(status: .disabled)
    )
    
    // MARK: - Computed
    var currentReview: ReviewEntity { examinateViewDatas.value.reviews[examinateViewDatas.value.index] }
    var isLastReview: Bool { examinateViewDatas.value.reviews.count == examinateViewDatas.value.index + 1 }
    
    init(todoCertificationsUseCase: TodoCertificationsUseCase) {
        self.todoCertificationsUseCase = todoCertificationsUseCase
    }

    var output: Output {
        Output(
            examinateViewDatas: examinateViewDatas.asDriver(),
            examinateButtonViewDatas: examinateButtonViewDatas.asDriver()
        )
    }

    func setDatas(_ datas: ExaminateViewDatas) {
        examinateViewDatas.accept(datas)
    }
    
    func setIndex(direction: Directions) {
        examinateViewDatas.update {
            $0.index = examinateViewDatas.value.index + direction.tag
        }
    }
    
    func setReviews(reviews: [ReviewEntity]) {
        examinateViewDatas.update {
            $0.index = 0
            $0.reviews = reviews
        }
    }
    
    func setResult(result: ReviewResults? = nil) {
        examinateViewDatas.update {
            $0.result = result
        }
    }
    
    func setFeedback(feedback: String = "") {
        examinateViewDatas.update {
            $0.feedback = feedback
        }
    }
    
    func setButtonStatus(status: ButtonStatus) {
        examinateButtonViewDatas.update {
            $0.status = status
        }
    }
    
    func reviewTodo() async throws {
        try await todoCertificationsUseCase.reviewTodo(
            todoId: String(currentReview.id),
            result: examinateViewDatas.value.result,
            reviewFeedback: examinateViewDatas.value.feedback
        )
    }
}
