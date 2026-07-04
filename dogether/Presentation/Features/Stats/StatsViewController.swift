//
//  StatsViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import UIKit

final class StatsViewController: BaseViewController {
    private let statsPage = StatsPage()
    private let viewModel = StatsViewModel()

    override func viewDidLoad() {
        statsPage.delegate = self
        
        pages = [statsPage]
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadStatsView()
        
        self.coordinator?.updateViewController = loadStatsView
    }

    override func setViewDatas() {
        bind(self.viewModel.bottomSheetViewDatas)
        bind(self.viewModel.groupViewDatas)
        bind(self.viewModel.achievementViewDatas)
        bind(self.viewModel.myRankViewDatas)
        bind(self.viewModel.summaryViewDatas)
    }
}

extension StatsViewController {
    private func loadStatsView() {
        runTask { [weak self] in
            guard let self else { return }
            try await self.viewModel.loadStatsView()
        }
    }
    
    private func reloadStats() {
        runTask { [weak self] in
            guard let self else { return }
            try await self.viewModel.fetchStatsViewDatas()
        }
    }
}

protocol StatsDelegate {
    func updateBottomSheetVisibleAction(isShowSheet: Bool)
    func selectGroupAction(index: Int)
    func addGroupAction()
}

extension StatsViewController: StatsDelegate {
    func updateBottomSheetVisibleAction(isShowSheet: Bool) {
        self.viewModel.bottomSheetViewDatas.update { $0.isShowSheet = isShowSheet }
    }
    
    func selectGroupAction(index: Int) {
        self.viewModel.groupViewDatas.update { $0.index = index }
        
        runTask { [weak self] in
            guard let self else { return }
            try await self.viewModel.saveLastSelectedGroupIndex(index: index)
            try await self.viewModel.fetchStatsViewDatas()
        }
    }
    
    func addGroupAction() {
        self.coordinator?.pushViewController(GroupCreateViewController())
    }
}
