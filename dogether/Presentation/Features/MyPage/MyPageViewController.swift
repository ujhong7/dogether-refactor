//
//  MyPageViewController.swift
//  dogether
//
//  Created by seungyooooong on 3/31/25.
//

import UIKit

final class MyPageViewController: BaseViewController {
    private let myPage = MyPagePage()
    private let viewModel: MyPageViewModel

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        myPage.delegate = self
        
        pages = [myPage]
        
        super.viewDidLoad()
        
        onAppear()
    }
    
    override func setViewDatas() {
        bind(viewModel.profileViewDatas)
        bind(viewModel.statsButtonViewDatas)
    }
}

extension MyPageViewController {
    private func onAppear() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.loadProfileView()
        }
    }
}

@MainActor
protocol MyPageDelegate: AnyObject {
    func goStatsViewAction()
    func goMyTodoListAction()
    func goGroupManagementAction()
    func goSettingViewAction()
}

extension MyPageViewController: MyPageDelegate {
    func goStatsViewAction() {
        guard let coordinator else { return }
        coordinator.pushStats()
    }
    func goMyTodoListAction() {
        guard let coordinator else { return }
        coordinator.pushCertificationList()
    }
    func goGroupManagementAction() {
        guard let coordinator else { return }
        coordinator.pushGroupManagement()
    }
    func goSettingViewAction() {
        guard let coordinator else { return }
        coordinator.pushSetting()
    }
}
