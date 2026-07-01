//
//  MainViewModel.swift
//  dogether
//
//  Created by seungyooooong on 2/13/25.
//

import UIKit

import RxRelay

@MainActor
final class MainViewModel {
    private let groupUseCase: GroupUseCase
    private let challengeGroupsUseCase: ChallengeGroupUseCase
    private let todoCertificationsUseCase: TodoCertificationsUseCase
    
    private(set) var bottomSheetViewDatas = BehaviorRelay<BottomSheetViewDatas>(value: BottomSheetViewDatas())
    private(set) var groupViewDatas = BehaviorRelay<GroupViewDatas>(value: GroupViewDatas())
    private(set) var sheetViewDatas = BehaviorRelay<SheetViewDatas>(value: SheetViewDatas())
    
    private(set) var timerViewDatas = BehaviorRelay<TimerViewDatas>(value: TimerViewDatas())
    private(set) var timer: Timer?
    
    // MARK: - Computed
    var currentGroup: GroupEntity { groupViewDatas.value.groups[groupViewDatas.value.index] }
    
    init() {
        let groupRepository = DIManager.shared.getGroupRepository()
        let challengeGroupsRepository = DIManager.shared.getChallengeGroupsRepository()
        let todoCertificationsRepository = DIManager.shared.getTodoCertificationsRepository()
        
        self.groupUseCase = GroupUseCase(repository: groupRepository)
        self.challengeGroupsUseCase = ChallengeGroupUseCase(repository: challengeGroupsRepository)
        self.todoCertificationsUseCase = TodoCertificationsUseCase(repository: todoCertificationsRepository)
    }
}

// MARK: - get
extension MainViewModel {
    func getGroups() async throws -> GroupViewDatas {
        return try await groupUseCase.getGroups()
    }
    
    func getTodoList(dateOffset: Int, groupId: Int) async throws -> [TodoEntity] {
        let date = DateFormatterManager.formattedDate(dateOffset).split(separator: ".").joined(separator: "-")
        return try await challengeGroupsUseCase.getMyTodos(groupId: groupId, date: date)
    }
    
    func getReviews() async throws -> [ReviewEntity] {
        return try await todoCertificationsUseCase.getReviews()
    }
}

// MARK: - set
extension MainViewModel {
    func setSheetViewDatasForCurrentGroup() async throws {
        if currentGroup.status == .ready {
            sheetViewDatas.update { $0.status = .timer }
            return
        }
        
        let dateOffset = sheetViewDatas.value.dateOffset
        if currentGroup.status == .dDay && dateOffset == 0 {
            sheetViewDatas.update { $0.status = .done }
            return
        }
        
        let todoList = try await getTodoList(dateOffset: dateOffset, groupId: currentGroup.id)
        sheetViewDatas.update {
            $0.todoList = todoList
            $0.status = dateOffset == 0 && todoList.isEmpty ? .createTodo :
            dateOffset == 0 && todoList.count > 0 ? .certificateTodo :
            dateOffset < 0 && todoList.isEmpty ? .emptyList : .todoList
        }
    }
}

// MARK: - ready
extension MainViewModel {
    func startTimer() {
        calculateRemainTime()
        // MARK: ViewModel이 @MainActor라 startTimer는 메인에서 호출됨 → Timer도 메인 런루프에 등록됨
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.calculateRemainTime()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func calculateRemainTime() {
        let remainTime = Date().getRemainTime()
        
        if remainTime > 0 {
            timerViewDatas.update {
                $0.time = remainTime.formatToHHmmss()
                $0.timeProgress = remainTime.getTimeProgress()
            }
        } else {
            stopTimer()
        }
    }
}

extension MainViewModel {
    func saveLastSelectedGroupIndex(index: Int) {
        Task { [weak self] in
            guard let self else { return }
            try await groupUseCase.saveLastSelectedGroup(groupId: groupViewDatas.value.groups[index].id)
        }
    }
}
