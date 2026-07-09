//
//  RankingViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/14/25.
//

import UIKit

final class RankingViewController: BaseViewController {
    private let rankingPage = RankingPage()
    private let viewModel: RankingViewModel

    init(viewModel: RankingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        rankingPage.delegate = self
        
        pages = [rankingPage]
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRankingView()
        
        coordinator?.setRefreshAction(loadRankingView)
    }
    
    override func setViewDatas() {
        guard let datas = datas as? RankingViewDatas else { return }
        viewModel.rankingViewDatas.accept(datas)
        
        bind(viewModel.rankingViewDatas)
    }
}

extension RankingViewController {
    private func loadRankingView() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.loadRankingView()
        }
    }
}

// MARK: - delegate
@MainActor
protocol RankingDelegate {
    func goCertificationViewAction(rankingEntity: RankingEntity)
}

extension RankingViewController: RankingDelegate {
    func goCertificationViewAction(rankingEntity: RankingEntity) {
        runTask { [weak self] in
            guard let self else { return }
            let (index, todos) = try await viewModel.getMemberTodos(memberId: rankingEntity.memberId)

            guard let coordinator else { return }
            let certificationViewDatas = CertificationViewDatas(
                title: "\(rankingEntity.name)님의 인증 정보",
                todos: todos,
                index: index,
                groupId: viewModel.rankingViewDatas.value.groupId,
                rankingEntity: rankingEntity
            )
            coordinator.pushCertification(datas: certificationViewDatas)
        }
    }
}
