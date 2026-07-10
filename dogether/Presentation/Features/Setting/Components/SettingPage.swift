//
//  SettingPage.swift
//  dogether
//
//  Created by seungyooooong on 11/23/25.
//

import UIKit

import RxRelay
import SnapKit

final class SettingPage: BasePage {
    let logoutTapped = PublishRelay<Void>()
    let withdrawTapped = PublishRelay<Void>()
    
    private let navigationHeader = NavigationHeader(title: "설정")
    private let logoutButton = SettingButton(title: "로그아웃")
    private let withdrawButton = SettingButton(title: "회원탈퇴")
    private let testButton = SettingButton(title: "앱 버전", text: SystemManager.appVersion)
    private let settingStackView = UIStackView()
    
    
    override func configureView() {
        settingStackView.axis = .vertical
    }
    
    override func configureAction() {
        navigationHeader.delegate = coordinatorDelegate

        logoutButton.addAction(
            UIAction { [weak self] _ in
                self?.logoutTapped.accept(())
            }, for: .touchUpInside
        )

        withdrawButton.addAction(
            UIAction { [weak self] _ in
                self?.withdrawTapped.accept(())
            }, for: .touchUpInside
        )
    }
    
    override func configureHierarchy() {
        [logoutButton, withdrawButton, testButton].forEach { settingStackView.addArrangedSubview($0) }
        
        [navigationHeader, settingStackView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        navigationHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        settingStackView.snp.makeConstraints {
            $0.top.equalTo(navigationHeader.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
