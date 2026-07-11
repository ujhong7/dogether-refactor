//
//  CertificationListPage.swift
//  dogether
//
//  Created by yujaehong on 12/8/25.
//

import UIKit

import RxRelay
import RxSwift

final class CertificationListPage: BasePage {
    let bottomSheetVisibleChanged = PublishRelay<Bool>()
    let sortSelected = PublishRelay<Int>()
    let filterSelected = PublishRelay<FilterTypes>()
    let certificationSelected = PublishRelay<(title: String, todos: [TodoEntity], index: Int)>()
    let reachedBottom = PublishRelay<Void>()
    
    private let navigationHeader = NavigationHeader(title: "인증 목록")
    private let emptyView = CertificationListEmptyView()
    private let contentView = CertificationListContentView()
    private let bottomSheetView = BottomSheetView(hasAddButton: false)
    private let disposeBag = DisposeBag()
    
    override func configureView() { }
    
    override func configureAction() {
        navigationHeader.delegate = coordinatorDelegate

        contentView.sortTapped
            .map { true }
            .bind(to: bottomSheetVisibleChanged)
            .disposed(by: disposeBag)

        contentView.filterSelected
            .bind(to: filterSelected)
            .disposed(by: disposeBag)

        contentView.certificationSelected
            .bind(to: certificationSelected)
            .disposed(by: disposeBag)

        contentView.reachedBottom
            .bind(to: reachedBottom)
            .disposed(by: disposeBag)

        bottomSheetView.isVisibleChanged
            .bind(to: bottomSheetVisibleChanged)
            .disposed(by: disposeBag)

        bottomSheetView.itemSelected
            .bind(to: sortSelected)
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [navigationHeader, emptyView, contentView, bottomSheetView].forEach { addSubview($0) }
    }
    
    override func configureConstraints() {
        navigationHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalTo(navigationHeader.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(navigationHeader.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - updateView
    func updateBottomSheet(_ datas: BottomSheetViewDatas) {
        bottomSheetView.updateView(datas)
    }

    func updateSort(_ datas: SortViewDatas) {
        contentView.updateView(datas)
        bottomSheetView.updateView(datas)
    }

    func updateStats(_ datas: StatsViewDatas) {
        contentView.updateView(datas)
    }

    func updateCertificationList(_ datas: CertificationListViewDatas) {
        emptyView.isHidden = !datas.sections.isEmpty
        contentView.isHidden = datas.sections.isEmpty

        contentView.updateView(datas)
    }

    override func updateView(_ data: any BaseEntity) {
        if let datas = data as? BottomSheetViewDatas {
            updateBottomSheet(datas)
        }
        
        if let datas = data as? SortViewDatas {
            updateSort(datas)
        }
        
        if let datas = data as? StatsViewDatas {
            updateStats(datas)
        }

        if let datas = data as? CertificationListViewDatas {
            updateCertificationList(datas)
        }
    }
}
