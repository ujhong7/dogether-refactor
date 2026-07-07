//
//  StartViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/9/25.
//

final class StartViewController: BaseViewController {
    private let startPage = StartPage()
    private let viewModel = StartViewModel()

    override func viewDidLoad() {
        startPage.delegate = self
        
        pages = [startPage]
        
        super.viewDidLoad()
        
        onAppear()
    }
    
    override func setViewDatas() {
        if let datas = datas as? StartViewDatas {
            viewModel.startViewDatas.accept(datas)
        }
        
        bind(viewModel.startViewDatas)
    }
}

extension StartViewController {
    private func onAppear() {
        if let code = DeepLinkManager.shared.consumeInviteCode() {
            guard let coordinator else { return }
            let groupJoinViewController = coordinator.appFactory.makeGroupJoinViewController()
            let groupJoinViewDatas = GroupJoinViewDatas(code: code)
            coordinator.pushViewController(groupJoinViewController, datas: groupJoinViewDatas)
        }
    }
}

// MARK: - delegate
@MainActor
protocol StartDelegate {
    func startAction(_ groupType: GroupTypes)
}

extension StartViewController: StartDelegate {
    func startAction(_ groupType: GroupTypes) {
        guard let coordinator else { return }

        switch groupType {
        case .create:
            coordinator.pushViewController(coordinator.appFactory.makeGroupCreateViewController())
        case .join:
            coordinator.pushViewController(coordinator.appFactory.makeGroupJoinViewController())
        }
    }
}
