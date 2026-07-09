//
//  CertificationListViewModel.swift
//  dogether
//
//  Created by yujaehong on 4/23/25.
//

import RxCocoa
import RxRelay

@MainActor
final class CertificationListViewModel {
    struct Output {
        let bottomSheetViewDatas: Driver<BottomSheetViewDatas>
        let statsViewDatas: Driver<StatsViewDatas>
        let sortViewDatas: Driver<SortViewDatas>
        let certificationListViewDatas: Driver<CertificationListViewDatas>
    }

    private let userUseCase: UserUseCase
    
    private let bottomSheetViewDatas = BehaviorRelay<BottomSheetViewDatas>(value: BottomSheetViewDatas())
    private let statsViewDatas = BehaviorRelay<StatsViewDatas>(value: StatsViewDatas())
    private let sortViewDatas = BehaviorRelay<SortViewDatas>(value: SortViewDatas())
    private let certificationListViewDatas = BehaviorRelay<CertificationListViewDatas>(
        value: CertificationListViewDatas()
    )

    var nextPage: Int { certificationListViewDatas.value.currentPage + 1 }
    
    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }

    var output: Output {
        Output(
            bottomSheetViewDatas: bottomSheetViewDatas.asDriver(),
            statsViewDatas: statsViewDatas.asDriver(),
            sortViewDatas: sortViewDatas.asDriver(),
            certificationListViewDatas: certificationListViewDatas.asDriver()
        )
    }
}

extension CertificationListViewModel {
    func updateBottomSheetVisible(isShowSheet: Bool) {
        bottomSheetViewDatas.update { $0.isShowSheet = isShowSheet }
    }

    func updateSortIndex(index: Int) {
        sortViewDatas.update { $0.index = index }
    }
    
    func updateFilter(filter: FilterTypes) {
        let filter: FilterTypes = (certificationListViewDatas.value.filter == filter) ? .all : filter
        certificationListViewDatas.update { $0.filter = filter }
    }
}

extension CertificationListViewModel {
    func loadCertificationList(page: Int) async throws {
        if page > 0 && certificationListViewDatas.value.isLastPage { return }
        try await fetchCertificationListViewDatas(page: page)
    }
}

extension CertificationListViewModel {
    private func fetchCertificationListViewDatas(page: Int) async throws {
        let (statsViewDatas, certificationListViewDatas) = try await userUseCase.getCertificationListViewDatas(
            option: sortViewDatas.value.options[sortViewDatas.value.index],
            page: page
        )
        
        self.statsViewDatas.accept(statsViewDatas)
        self.certificationListViewDatas.update {
            let newSections = certificationListViewDatas.sections
            $0.sections = page == 0 ? newSections : $0.sections + newSections
            $0.currentPage = page
            $0.isLastPage = certificationListViewDatas.isLastPage
        }
    }
}
