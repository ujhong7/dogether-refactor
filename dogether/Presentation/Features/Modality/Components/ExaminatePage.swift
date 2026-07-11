//
//  ExaminatePage.swift
//  dogether
//
//  Created by seungyooooong on 12/4/25.
//

import UIKit

import RxRelay

final class ExaminatePage: BasePage {
    let examinateSelected = PublishRelay<FilterTypes>()
    let sendTapped = PublishRelay<Void>()
    
    private let scrollView = UIScrollView()
    private let sendButton = DogetherButton("보내기")
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionView = ExaminateDescriptionView()
    private let imageView = CertificationImageView(type: .logo)
    private let contentLabel = UILabel()
    private let rejectButton = ExaminateButton(type: .reject)
    private let approveButton = ExaminateButton(type: .approve)
    private let examinationStackView = UIStackView()
    private let reviewFeedbackView = ReviewFeedbackView()
    
    private(set) var currentReview: ReviewEntity?
    private(set) var currentFeedback: String?
    private(set) var currentResult: ReviewResults?
    
    override func configureView() {
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        
        titleLabel.text = "투두를 검사해주세요!"
        titleLabel.textColor = .grey0
        titleLabel.font = Fonts.head1B
        titleLabel.textAlignment = .center
        
        contentLabel.textColor = .grey0
        contentLabel.numberOfLines = 0
        
        examinationStackView.axis = .horizontal
        examinationStackView.spacing = 8
        examinationStackView.distribution = .fillEqually
    }
    
    override func configureAction() {
        [rejectButton, approveButton].forEach { button in
            button.addAction(
                UIAction { [weak self, weak button] _ in
                    guard let self, let button,
                          let type = FilterTypes.allCases.first(where: { $0.tag == button.tag }) else { return }
                    examinateSelected.accept(type)
                }, for: .touchUpInside
            )
        }

        sendButton.addAction(
            UIAction { [weak self] _ in
                self?.sendTapped.accept(())
            }, for: .touchUpInside
        )
    }
    
    override func configureHierarchy() {
        [rejectButton, approveButton].forEach { examinationStackView.addArrangedSubview($0) }
        
        [ titleLabel, descriptionView,
          imageView, contentLabel, examinationStackView
        ].forEach { contentStackView.addArrangedSubview($0) }
        contentStackView.setCustomSpacing(4, after: titleLabel)
        contentStackView.setCustomSpacing(24, after: descriptionView)
        contentStackView.setCustomSpacing(16, after: imageView)
        contentStackView.setCustomSpacing(16, after: contentLabel)
        
        [scrollView, sendButton].forEach { addSubview($0) }
        [contentStackView].forEach { scrollView.addSubview($0) }
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(50 + 16 + 16)
            $0.horizontalEdges.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview().inset(16)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(36)
        }
        
        descriptionView.snp.makeConstraints {
            $0.height.equalTo(25)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(scrollView.snp.width).offset(-32)
        }
        
        examinationStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
    }
    
    // MARK: - updateView
    func updateExaminate(_ datas: ExaminateViewDatas) {
        guard datas.reviews.indices.contains(datas.index) else { return }
        let selectedReview = datas.reviews[datas.index]

        if currentReview != selectedReview {
            currentReview = selectedReview

            let certificationImageViewDatas = CertificationImageViewDatas(
                image: .logo,
                imageUrl: selectedReview.mediaUrl,
                content: selectedReview.content,
                certificator: selectedReview.doer
            )
            imageView.updateView(certificationImageViewDatas)

            contentLabel.attributedText = NSAttributedString(
                string: selectedReview.todoContent,
                attributes: Fonts.getAttributes(for: Fonts.head2B, textAlignment: .center)
            )
        }

        if currentFeedback != datas.feedback {
            currentFeedback = datas.feedback

            reviewFeedbackView.updateView(datas.feedback)
            if datas.feedback.isEmpty {
                contentStackView.removeArrangedSubview(reviewFeedbackView)

                reviewFeedbackView.snp.removeConstraints()
            } else {
                contentStackView.addArrangedSubview(reviewFeedbackView)
                contentStackView.setCustomSpacing(16, after: examinationStackView)

                reviewFeedbackView.snp.makeConstraints {
                    $0.horizontalEdges.equalToSuperview()
                }
            }
        }

        if currentResult != datas.result {
            currentResult = datas.result

            rejectButton.updateView(datas.result == .reject ? .dogetherRed : .grey0)
            approveButton.updateView(datas.result == .approve ? .blue300 : .grey0)
        }
    }

    func updateSendButton(_ datas: DogetherButtonViewDatas) {
        sendButton.updateView(datas)
    }

    override func updateView(_ data: (any BaseEntity)?) {
        if let datas = data as? ExaminateViewDatas {
            updateExaminate(datas)
        }
            
            
        if let datas = data as? DogetherButtonViewDatas {
            updateSendButton(datas)
        }
    }
}
