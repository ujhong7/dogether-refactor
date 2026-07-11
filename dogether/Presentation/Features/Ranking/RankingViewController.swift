//
//  RankingViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/14/25.
//

import UIKit

import RxCocoa
import RxSwift

final class RankingViewController: BaseViewController {
    private let rankingPage = RankingPage()
    private let viewModel: RankingViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: RankingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
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
        viewModel.setDatas(datas)

        let output = viewModel.output
        bind(output.rankingViewDatas, update: rankingPage.updateRanking)

        rankingPage.rankingSelected
            .asSignal()
            .emit(onNext: { [weak self] ranking in
                self?.goCertificationView(rankingEntity: ranking)
            })
            .disposed(by: disposeBag)
    }
}

extension RankingViewController {
    private func loadRankingView() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.loadRankingView()
        }
    }

    private func goCertificationView(rankingEntity: RankingEntity) {
        runTask { [weak self] in
            guard let self else { return }
            let (index, todos) = try await viewModel.getMemberTodos(memberId: rankingEntity.memberId)

            guard let coordinator else { return }
            let certificationViewDatas = CertificationViewDatas(
                title: "\(rankingEntity.name)님의 인증 정보",
                todos: todos,
                index: index,
                groupId: viewModel.groupId,
                rankingEntity: rankingEntity
            )
            coordinator.pushCertification(datas: certificationViewDatas)
        }
    }
}
