//
//  GroupCreateViewModel.swift
//  dogether
//
//  Created by seungyooooong on 2/10/25.
//

import Foundation

import RxCocoa
import RxRelay
import RxSwift

@MainActor
final class GroupCreateViewModel {
    struct Input {
        let viewDidAppear: Signal<Void>
        let stepChanged: Signal<CreateGroupSteps?>
        let groupNameChanged: Signal<String>
        let memberCountChanged: Signal<(count: Int, min: Int, max: Int)>
        let durationSelected: Signal<GroupChallengeDurations>
        let startAtSelected: Signal<GroupStartAts>
    }

    struct Output {
        let groupCreateViewDatas: Driver<GroupCreateViewDatas>
    }

    private let groupUseCase: GroupUseCase
    private let disposeBag = DisposeBag()
    
    private let groupCreateViewDatas = BehaviorRelay<GroupCreateViewDatas>(value: GroupCreateViewDatas())

    var groupName: String { groupCreateViewDatas.value.groupName }
    
    init(groupUseCase: GroupUseCase) {
        self.groupUseCase = groupUseCase
    }

    func transform(input: Input) -> Output {
        input.viewDidAppear
            .emit(onNext: { [weak self] in
                self?.updateIsFirstResponder(isFirstResponder: true)
            })
            .disposed(by: disposeBag)

        input.stepChanged
            .emit(onNext: { [weak self] step in
                self?.updateStep(step: step)
            })
            .disposed(by: disposeBag)

        input.groupNameChanged
            .emit(onNext: { [weak self] groupName in
                self?.updateGroupName(groupName: groupName)
            })
            .disposed(by: disposeBag)

        input.memberCountChanged
            .emit(onNext: { [weak self] count, min, max in
                self?.updateMemberCount(count: count, min: min, max: max)
            })
            .disposed(by: disposeBag)

        input.durationSelected
            .emit(onNext: { [weak self] duration in
                self?.updateDuration(duration: duration)
            })
            .disposed(by: disposeBag)

        input.startAtSelected
            .emit(onNext: { [weak self] startAt in
                self?.updateStartAt(startAt: startAt)
            })
            .disposed(by: disposeBag)

        return Output(groupCreateViewDatas: groupCreateViewDatas.asDriver())
    }
}

extension GroupCreateViewModel {
    func updateIsFirstResponder(isFirstResponder: Bool) {
        groupCreateViewDatas.update { $0.isFirstResponder = isFirstResponder }
    }
    
    func updateStep(step: CreateGroupSteps?) {
        guard let step else { return }
        groupCreateViewDatas.update { $0.step = step }
    }
    
    func updateGroupName(groupName: String) {
        groupCreateViewDatas.update { $0.groupName = groupName }
    }
    
    func updateMemberCount(count: Int, min: Int, max: Int) {
        let isValidate = groupUseCase.validateMemberCount(count: count, min: min, max: max)
        if isValidate { groupCreateViewDatas.update { $0.memberCount = count } }
    }
    
    func updateDuration(duration: GroupChallengeDurations) {
        groupCreateViewDatas.update { $0.duration = duration }
    }
    
    func updateStartAt(startAt: GroupStartAts) {
        groupCreateViewDatas.update { $0.startAt = startAt }
    }
}

extension GroupCreateViewModel {
    func createGroup() async throws -> String {
        try await groupUseCase.createGroup(groupCreateViewDatas: groupCreateViewDatas.value)
    }
}
