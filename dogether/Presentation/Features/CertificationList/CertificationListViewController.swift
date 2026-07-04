//
//  CertificationListViewController.swift
//  dogether
//
//  Created by yujaehong on 4/21/25.
//

final class CertificationListViewController: BaseViewController {
    private let certificationListPage = CertificationListPage()
    private let viewModel = CertificationListViewModel()
    
    override func viewDidLoad() {
        certificationListPage.delegate = self
        
        pages = [certificationListPage]
        
        super.viewDidLoad()
        
        onAppear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FIXME: 추후에 API 세분화 되면 Stats API만 updateViewController 지정, 호출 필요 x
//        self.coordinator?.updateViewController = loadSummaryView
    }
    
    override func setViewDatas() {
        bind(self.viewModel.bottomSheetViewDatas)
        bind(self.viewModel.sortViewDatas)
        bind(self.viewModel.statsViewDatas)
        bind(self.viewModel.certificationListViewDatas)
    }
}

extension CertificationListViewController {
    private func onAppear() {
        loadCertificationListView()
    }
    
    private func loadCertificationListView(page: Int = 0) {
        runTask { [self] in
            try await self.viewModel.loadCertificationList(page: page)
        }
    }
}

protocol CertificationListPageDelegate {
    func updateBottomSheetVisibleAction(isShowSheet: Bool)
    func selectSortAction(index: Int)
    func selectFilterAction(filterType: FilterTypes)
    func selectCertificationAction(title: String, todos: [TodoEntity], index: Int)
    func didScrollToBottom()
}

extension CertificationListViewController: CertificationListPageDelegate {
    func updateBottomSheetVisibleAction(isShowSheet: Bool) {
        self.viewModel.bottomSheetViewDatas.update { $0.isShowSheet = isShowSheet }
    }
    
    func selectSortAction(index: Int) {
        self.viewModel.updateSortIndex(index: index)
        
        loadCertificationListView()
    }
    
    func selectFilterAction(filterType: FilterTypes) {
        self.viewModel.updateFilter(filter: filterType)
    }
    
    func selectCertificationAction(title: String, todos: [TodoEntity], index: Int) {
        let certificationViewController = CertificationViewController()
        let certificationViewDatas = CertificationViewDatas(title: title, todos: todos, index: index)
        self.coordinator?.pushViewController(certificationViewController, datas: certificationViewDatas)
    }
    
    func didScrollToBottom() {
        loadCertificationListView(page: self.viewModel.certificationListViewDatas.value.currentPage + 1)
    }
}
