//
//  StartViewModel.swift
//  dogether
//
//  Created by seungyooooong on 8/19/25.
//

import RxRelay

@MainActor
final class StartViewModel {
    private(set) var startViewDatas = BehaviorRelay<StartViewDatas>(value: StartViewDatas())
}
