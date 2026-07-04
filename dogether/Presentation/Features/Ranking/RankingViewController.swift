//
//  RankingViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/14/25.
//

import UIKit

final class RankingViewController: BaseViewController {
    private let rankingPage = RankingPage()
    private let viewModel = RankingViewModel()
    
    override func viewDidLoad() {
        rankingPage.delegate = self
        
        pages = [rankingPage]
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRankingView()
        
        self.coordinator?.updateViewController = loadRankingView
    }
    
    override func setViewDatas() {
        guard let datas = datas as? RankingViewDatas else { return }
        self.viewModel.rankingViewDatas.accept(datas)
        
        bind(self.viewModel.rankingViewDatas)
    }
}

extension RankingViewController {
    private func loadRankingView() {
        runTask { [self] in
            try await self.viewModel.loadRankingView()
        }
    }
}

// MARK: - delegate
protocol RankingDelegate {
    func goCertificationViewAction(rankingEntity: RankingEntity)
}

extension RankingViewController: RankingDelegate {
    func goCertificationViewAction(rankingEntity: RankingEntity) {
        runTask { [self] in
            let (index, todos) = try await self.viewModel.getMemberTodos(memberId: rankingEntity.memberId)

            let certificationViewController = CertificationViewController()
            let certificationViewDatas = CertificationViewDatas(
                title: "\(rankingEntity.name)님의 인증 정보",
                todos: todos,
                index: index,
                groupId: self.viewModel.rankingViewDatas.value.groupId,
                rankingEntity: rankingEntity
            )
            self.coordinator?.pushViewController(certificationViewController, datas: certificationViewDatas)
        }
    }
}
