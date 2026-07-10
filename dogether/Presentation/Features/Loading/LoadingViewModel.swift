//
//  LoadingViewModel.swift
//  dogether
//
//  Created by seungyooooong on 12/29/25.
//

import RxCocoa
import RxRelay

@MainActor
final class LoadingViewModel {
    struct Output {
        let loadingViewDatas: Driver<LoadingViewDatas>
    }

    private let loadingViewDatas = BehaviorRelay<LoadingViewDatas>(value: LoadingViewDatas())

    var output: Output {
        Output(loadingViewDatas: loadingViewDatas.asDriver())
    }

    func setDatas(_ datas: LoadingViewDatas) {
        loadingViewDatas.accept(datas)
    }
    
    func updateIsShowLoading(isShowLoading: Bool) {
        loadingViewDatas.update {
            $0.isShowLoading = isShowLoading
        }
    }
}
