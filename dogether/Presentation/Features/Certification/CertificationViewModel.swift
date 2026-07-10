//
//  CertificationViewModel.swift
//  dogether
//
//  Created by seungyooooong on 10/18/25.
//

import RxCocoa
import RxRelay

@MainActor
final class CertificationViewModel {
    struct Output {
        let certificationViewDatas: Driver<CertificationViewDatas>
    }

    private let challengeGroupsUseCase: ChallengeGroupUseCase
    
    private let certificationViewDatas = BehaviorRelay<CertificationViewDatas>(value: CertificationViewDatas())
    
    init(challengeGroupsUseCase: ChallengeGroupUseCase) {
        self.challengeGroupsUseCase = challengeGroupsUseCase
    }

    var output: Output {
        Output(certificationViewDatas: certificationViewDatas.asDriver())
    }

    func setDatas(_ datas: CertificationViewDatas) {
        certificationViewDatas.accept(datas)
    }
}

extension CertificationViewModel {
    func setIndex(index: Int) async throws {
        if certificationViewDatas.value.rankingEntity == nil {
            certificationViewDatas.update { $0.index = index }
        } else {
            // MARK: 이전에 보고 있던 thumbnailStatus를 수정하고 이동한 todo의 read API를 호출
            certificationViewDatas.update { $0.todos[certificationViewDatas.value.index].thumbnailStatus = .done }
            certificationViewDatas.update { $0.index = index }
            try await readTodo(index: index)
        }
    }
    
    func readTodo(index: Int? = nil) async throws {
        if certificationViewDatas.value.rankingEntity == nil { return }
        try await challengeGroupsUseCase.readTodo(
            todo: certificationViewDatas.value.todos[index ?? certificationViewDatas.value.index]
        )
    }
}
