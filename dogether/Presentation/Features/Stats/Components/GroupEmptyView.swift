//
//  StatsEmptyView.swift
//  dogether
//
//  Created by yujaehong on 4/23/25.
//

import UIKit

import RxRelay

final class GroupEmptyView: BaseView {
    let createGroupTapped = PublishRelay<Void>()
    
    private let emptyStateView = EmptyStateView(
        title: "소속된 그룹이 없어요",
        description: "새로운 그룹을 만들어 함께 시작해보세요!"
    )
    private let createGroupButton = DogetherButton("그룹 만들기")
    
    override func configureView() {
        // FIXME: GroupManagementViewController Rx 도입 이후 수정
        let dogetherButtonViewDatas = DogetherButtonViewDatas()
        createGroupButton.updateView(dogetherButtonViewDatas)
    }
    
    override func configureAction() {
        createGroupButton.addAction(
            UIAction { [weak self] _ in
                self?.createGroupTapped.accept(())
            },
            for: .touchUpInside
        )
    }
    
    override func configureHierarchy() {
        addSubview(emptyStateView)
        addSubview(createGroupButton)
    }
    
    override func configureConstraints() {
        emptyStateView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(160)
            $0.centerX.equalToSuperview()
        }
        
        createGroupButton.snp.makeConstraints {
            $0.top.equalTo(emptyStateView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(169)
        }
    }
}
