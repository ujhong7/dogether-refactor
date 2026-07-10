//
//  ErrorViewModel.swift
//  dogether
//
//  Created by seungyooooong on 12/17/25.
//

import Foundation

import RxCocoa
import RxRelay

@MainActor
final class ErrorViewModel {
    struct Output {
        let buttonViewDatas: Driver<DogetherButtonViewDatas>
    }

    private let buttonViewDatas = BehaviorRelay<DogetherButtonViewDatas>(value: DogetherButtonViewDatas())

    var output: Output {
        Output(buttonViewDatas: buttonViewDatas.asDriver())
    }
}
