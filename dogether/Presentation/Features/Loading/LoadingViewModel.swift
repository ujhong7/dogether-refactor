//
//  LoadingViewModel.swift
//  dogether
//
//  Created by seungyooooong on 12/29/25.
//

import RxRelay

@MainActor
final class LoadingViewModel {
    private(set) var loadingViewDatas = BehaviorRelay<LoadingViewDatas>(value: LoadingViewDatas())
    
    func updateIsShowLoading(isShowLoading: Bool) {
        loadingViewDatas.update {
            $0.isShowLoading = isShowLoading
        }
    }
}
