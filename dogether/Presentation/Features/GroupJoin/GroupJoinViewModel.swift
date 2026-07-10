//
//  GroupJoinViewModel.swift
//  dogether
//
//  Created by seungyooooong on 3/26/25.
//

import Foundation

import RxCocoa
import RxRelay
import RxSwift

@MainActor
final class GroupJoinViewModel {
    struct Input {
        let viewDidAppear: Signal<Void>
        let codeChanged: Signal<String>
        let keyboardHeightChanged: Signal<CGFloat>
    }

    struct Output {
        let groupJoinViewDatas: Driver<GroupJoinViewDatas>
        let joinButtonViewDatas: Driver<DogetherButtonViewDatas>
    }

    private let groupUseCase: GroupUseCase
    private let disposeBag = DisposeBag()
    
    private let groupJoinViewDatas = BehaviorRelay<GroupJoinViewDatas>(value: GroupJoinViewDatas())
    private let joinButtonViewDatas = BehaviorRelay<DogetherButtonViewDatas>(
        value: DogetherButtonViewDatas(status: .disabled)
    )
    
    init(groupUseCase: GroupUseCase) {
        self.groupUseCase = groupUseCase
    }

    func transform(input: Input) -> Output {
        input.viewDidAppear
            .emit(onNext: { [weak self] in
                self?.updateIsFirstResponder(isFirstResponder: true)
            })
            .disposed(by: disposeBag)

        input.codeChanged
            .emit(onNext: { [weak self] code in
                self?.updateCode(code: code)
            })
            .disposed(by: disposeBag)

        input.keyboardHeightChanged
            .emit(onNext: { [weak self] height in
                self?.updateKeyboardHeight(height: height)
            })
            .disposed(by: disposeBag)

        return Output(
            groupJoinViewDatas: groupJoinViewDatas.asDriver(),
            joinButtonViewDatas: joinButtonViewDatas.asDriver()
        )
    }

    func setDatas(_ datas: GroupJoinViewDatas) {
        groupJoinViewDatas.accept(datas)
        updateButtonStatus(status: datas.code.count < 8 ? .disabled : .enabled)
    }
}

extension GroupJoinViewModel {
    func joinGroup() async throws -> GroupEntity {
        try await groupUseCase.joinGroup(joinCode: groupJoinViewDatas.value.code)
    }
}

extension GroupJoinViewModel {
    func updateIsFirstResponder(isFirstResponder: Bool) {
        groupJoinViewDatas.update { $0.isFirstResponder = isFirstResponder }
    }
    
    func updateKeyboardHeight(height: CGFloat) {
        groupJoinViewDatas.update { $0.keyboardHeight = height }
    }
    
    func updateCode(code: String) {
        groupJoinViewDatas.update { $0.code = code }
    }
    
    func updateButtonStatus(status: ButtonStatus) {
        joinButtonViewDatas.update { $0.status = status }
    }
}
