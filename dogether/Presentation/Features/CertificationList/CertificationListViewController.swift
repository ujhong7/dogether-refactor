//
//  CertificationListViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

import UIKit

import RxCocoa
import RxSwift

final class CertificationListViewController: BaseViewController {
    private let certificationListPage = CertificationListPage()
    private let viewModel: CertificationListViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: CertificationListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [certificationListPage]
        
        super.viewDidLoad()
        
        onAppear()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FIXME: 추후에 API 세분화 되면 Stats API만 refreshAction 지정, 호출 필요 x
//        coordinator?.setRefreshAction(loadSummaryView)
    }
    
    override func setViewDatas() {
        let output = viewModel.output
        bind(output.bottomSheetViewDatas, update: certificationListPage.updateBottomSheet)
        bind(output.sortViewDatas, update: certificationListPage.updateSort)
        bind(output.statsViewDatas, update: certificationListPage.updateStats)
        bind(output.certificationListViewDatas, update: certificationListPage.updateCertificationList)
    }
}

extension CertificationListViewController {
    private func onAppear() {
        loadCertificationListView()
    }
    
    private func loadCertificationListView(page: Int = 0) {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.loadCertificationList(page: page)
        }
    }

    private func bindActions() {
        certificationListPage.bottomSheetVisibleChanged
            .asSignal()
            .emit(onNext: { [weak self] isShowSheet in
                self?.viewModel.updateBottomSheetVisible(isShowSheet: isShowSheet)
            })
            .disposed(by: disposeBag)

        certificationListPage.sortSelected
            .asSignal()
            .emit(onNext: { [weak self] index in
                self?.selectSort(index: index)
            })
            .disposed(by: disposeBag)

        certificationListPage.filterSelected
            .asSignal()
            .emit(onNext: { [weak self] filterType in
                self?.viewModel.updateFilter(filter: filterType)
            })
            .disposed(by: disposeBag)

        certificationListPage.certificationSelected
            .asSignal()
            .emit(onNext: { [weak self] selected in
                self?.selectCertification(title: selected.title, todos: selected.todos, index: selected.index)
            })
            .disposed(by: disposeBag)

        certificationListPage.reachedBottom
            .asSignal()
            .emit(onNext: { [weak self] in
                guard let self else { return }
                loadCertificationListView(page: viewModel.nextPage)
            })
            .disposed(by: disposeBag)
    }

    private func selectSort(index: Int) {
        viewModel.updateSortIndex(index: index)
        loadCertificationListView()
    }

    private func selectCertification(title: String, todos: [TodoEntity], index: Int) {
        guard let coordinator else { return }
        let certificationViewDatas = CertificationViewDatas(title: title, todos: todos, index: index)
        coordinator.pushCertification(datas: certificationViewDatas)
    }
}
