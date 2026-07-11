//
//  StatsViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import UIKit

import RxCocoa
import RxSwift

final class StatsViewController: BaseViewController {
    private let statsPage = StatsPage()
    private let viewModel: StatsViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: StatsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        pages = [statsPage]
        
        super.viewDidLoad()

        bindActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadStatsView()
        
        coordinator?.setRefreshAction(loadStatsView)
    }

    override func setViewDatas() {
        let output = viewModel.output
        bind(output.bottomSheetViewDatas, update: statsPage.updateView)
        bind(output.groupViewDatas, update: statsPage.updateView)
        bind(output.achievementViewDatas, update: statsPage.updateView)
        bind(output.myRankViewDatas, update: statsPage.updateView)
        bind(output.summaryViewDatas, update: statsPage.updateView)
    }
}

extension StatsViewController {
    private func loadStatsView() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.loadStatsView()
        }
    }
    
    private func reloadStats() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.fetchStatsViewDatas()
        }
    }

    private func bindActions() {
        statsPage.bottomSheetVisibleChanged
            .asSignal()
            .emit(onNext: { [weak self] isShowSheet in
                self?.viewModel.updateBottomSheetVisible(isShowSheet: isShowSheet)
            })
            .disposed(by: disposeBag)

        statsPage.groupSelected
            .asSignal()
            .emit(onNext: { [weak self] index in
                self?.selectGroup(index: index)
            })
            .disposed(by: disposeBag)

        statsPage.createGroupTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.addGroup()
            })
            .disposed(by: disposeBag)
    }

    private func selectGroup(index: Int) {
        viewModel.selectGroup(index: index)
        
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.saveLastSelectedGroupIndex(index: index)
            try await viewModel.fetchStatsViewDatas()
        }
    }

    private func addGroup() {
        guard let coordinator else { return }
        coordinator.pushGroupCreate()
    }
}
