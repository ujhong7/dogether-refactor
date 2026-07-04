//
//  MyPageViewController.swift
//  dogether
//
//  Created by seungyooooong on 3/31/25.
//

final class MyPageViewController: BaseViewController {
    private let myPage = MyPagePage()
    private let viewModel = MyPageViewModel()
    
    override func viewDidLoad() {
        myPage.delegate = self
        
        pages = [myPage]
        
        super.viewDidLoad()
        
        onAppear()
    }
    
    override func setViewDatas() {
        bind(self.viewModel.profileViewDatas)
        bind(self.viewModel.statsButtonViewDatas)
    }
}

extension MyPageViewController {
    private func onAppear() {
        runTask { [weak self] in
            guard let self else { return }
            try await self.viewModel.loadProfileView()
        }
    }
}

protocol MyPageDelegate: AnyObject {
    func goStatsViewAction()
    func goMyTodoListAction()
    func goGroupManagementAction()
    func goSettingViewAction()
}

extension MyPageViewController: MyPageDelegate {
    func goStatsViewAction() {
        self.coordinator?.pushViewController(StatsViewController())
    }
    func goMyTodoListAction() {
        self.coordinator?.pushViewController(CertificationListViewController())
    }
    func goGroupManagementAction() {
        self.coordinator?.pushViewController(GroupManagementViewController())
    }
    func goSettingViewAction() {
        self.coordinator?.pushViewController(SettingViewController())
    }
}
