//
//  GroupCreatePage.swift
//  dogether
//
//  Created by seungyooooong on 11/10/25.
//

import UIKit

import RxRelay
import RxSwift
import SnapKit

final class GroupCreatePage: BasePage {
    let stepChanged = PublishRelay<CreateGroupSteps?>()
    let groupNameChanged = PublishRelay<String>()
    let memberCountChanged = PublishRelay<(count: Int, min: Int, max: Int)>()
    let durationSelected = PublishRelay<GroupChallengeDurations>()
    let startAtSelected = PublishRelay<GroupStartAts>()
    let createTapped = PublishRelay<Void>()
    
    private let navigationHeader = NavigationHeader(title: "그룹 만들기")
    private let stepInfoStackView = StepInfoStackView()
    private let stepButtonStackView = StepButtonStackView()
    
    private var stepOneView = StepOneView()
    private var stepTwoView = StepTwoView()
    private var stepThreeView = StepThreeView()
    private let disposeBag = DisposeBag()
    
    override func configureView() { }
    
    override func configureAction() {
        addTapAction { [weak self] _ in
            guard let self else { return }
            endEditing(true)
        }

        navigationHeader.delegate = coordinatorDelegate

        stepButtonStackView.stepChanged
            .bind(to: stepChanged)
            .disposed(by: disposeBag)

        stepButtonStackView.createTapped
            .bind(to: createTapped)
            .disposed(by: disposeBag)

        stepOneView.groupNameChanged
            .bind(to: groupNameChanged)
            .disposed(by: disposeBag)

        stepOneView.memberCountChanged
            .bind(to: memberCountChanged)
            .disposed(by: disposeBag)

        stepTwoView.durationSelected
            .bind(to: durationSelected)
            .disposed(by: disposeBag)

        stepTwoView.startAtSelected
            .bind(to: startAtSelected)
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [ navigationHeader, stepInfoStackView, stepButtonStackView,
          stepOneView, stepTwoView, stepThreeView
        ].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        navigationHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        stepInfoStackView.snp.makeConstraints {
            $0.top.equalTo(navigationHeader.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        stepButtonStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        stepOneView.snp.makeConstraints {
            $0.top.equalTo(stepInfoStackView.snp.bottom).offset(40)
            $0.bottom.equalTo(stepButtonStackView.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        stepTwoView.snp.makeConstraints {
            $0.top.equalTo(stepInfoStackView.snp.bottom).offset(40)
            $0.bottom.equalTo(stepButtonStackView.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        stepThreeView.snp.makeConstraints {
            $0.top.equalTo(stepInfoStackView.snp.bottom).offset(84)
            $0.bottom.equalTo(stepButtonStackView.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(36)
        }
    }
    
    // MARK: - updateView
    func updateView(_ datas: GroupCreateViewDatas) {
        stepInfoStackView.updateView(datas)

        stepButtonStackView.updateView(datas)

        stepOneView.isHidden = datas.step != .one
        stepTwoView.isHidden = datas.step != .two
        stepThreeView.isHidden = datas.step != .three

        switch datas.step {
        case .one:
            stepOneView.updateView(datas)
        case .two:
            stepTwoView.updateView(datas)
            endEditing(true)
        case .three:
            stepThreeView.updateView(datas)
        }
    }

    override func updateView(_ data: (any BaseEntity)?) {
        if let datas = data as? GroupCreateViewDatas {
            updateView(datas)
        }
    }
}
