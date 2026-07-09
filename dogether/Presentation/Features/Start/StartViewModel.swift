//
//  StartViewModel.swift
//  dogether
//
//  Created by seungyooooong on 8/19/25.
//

import RxCocoa
import RxRelay

@MainActor
final class StartViewModel {
    struct Output {
        let startViewDatas: Driver<StartViewDatas>
    }

    private let startViewDatas = BehaviorRelay<StartViewDatas>(value: StartViewDatas())

    var output: Output {
        Output(startViewDatas: startViewDatas.asDriver())
    }

    func setDatas(_ datas: StartViewDatas) {
        startViewDatas.accept(datas)
    }
}
