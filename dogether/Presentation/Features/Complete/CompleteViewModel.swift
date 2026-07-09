//
//  CompleteViewModel.swift
//  dogether
//
//  Created by seungyooooong on 2/18/25.
//

import RxCocoa
import RxRelay

@MainActor
final class CompleteViewModel {
    struct Output {
        let completeViewDatas: Driver<CompleteViewDatas>
    }

    private let completeViewDatas = BehaviorRelay<CompleteViewDatas>(value: CompleteViewDatas())

    var currentDatas: CompleteViewDatas { completeViewDatas.value }

    var output: Output {
        Output(completeViewDatas: completeViewDatas.asDriver())
    }

    func setDatas(_ datas: CompleteViewDatas) {
        completeViewDatas.accept(datas)
    }
}
