//
//  MainViewModel.swift
//  dogether
//
//  Created by seungyooooong on 2/13/25.
//

import UIKit

import RxCocoa
import RxRelay

@MainActor
final class MainViewModel {
    struct Output {
        let bottomSheetViewDatas: Driver<BottomSheetViewDatas>
        let groupViewDatas: Driver<GroupViewDatas>
        let sheetViewDatas: Driver<SheetViewDatas>
        let timerViewDatas: Driver<TimerViewDatas>
    }

    private let groupUseCase: GroupUseCase
    private let challengeGroupsUseCase: ChallengeGroupUseCase
    private let todoCertificationsUseCase: TodoCertificationsUseCase
    
    private let bottomSheetViewDatas = BehaviorRelay<BottomSheetViewDatas>(value: BottomSheetViewDatas())
    private let groupViewDatas = BehaviorRelay<GroupViewDatas>(value: GroupViewDatas())
    private let sheetViewDatas = BehaviorRelay<SheetViewDatas>(value: SheetViewDatas())
    
    private let timerViewDatas = BehaviorRelay<TimerViewDatas>(value: TimerViewDatas())
    private var timer: Timer?
    
    // MARK: - Computed
    var currentGroup: GroupEntity { groupViewDatas.value.groups[groupViewDatas.value.index] }
    
    init(
        groupUseCase: GroupUseCase,
        challengeGroupsUseCase: ChallengeGroupUseCase,
        todoCertificationsUseCase: TodoCertificationsUseCase
    ) {
        self.groupUseCase = groupUseCase
        self.challengeGroupsUseCase = challengeGroupsUseCase
        self.todoCertificationsUseCase = todoCertificationsUseCase
    }

    var output: Output {
        Output(
            bottomSheetViewDatas: bottomSheetViewDatas.asDriver(),
            groupViewDatas: groupViewDatas.asDriver(),
            sheetViewDatas: sheetViewDatas.asDriver(),
            timerViewDatas: timerViewDatas.asDriver()
        )
    }
}

// MARK: - get
extension MainViewModel {
    func loadGroups() async throws -> Bool {
        let groupViewDatas: GroupViewDatas = try await groupUseCase.getGroups()
        self.groupViewDatas.accept(groupViewDatas)
        return groupViewDatas.groups.isEmpty
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
    func updateSheetAlpha(_ alpha: CGFloat) {
        sheetViewDatas.update { $0.alpha = alpha }
    }

    func updateSheetStatus(_ sheetStatus: SheetStatus) {
        sheetViewDatas.update { $0.sheetStatus = sheetStatus }
    }

    func updateSheetYOffset(_ yOffset: CGFloat) {
        sheetViewDatas.update { $0.yOffset = yOffset }
    }

    func updateIsScrollOnTop(_ isScrollOnTop: Bool) {
        sheetViewDatas.update { $0.isScrollOnTop = isScrollOnTop }
    }

    func updateBottomSheetVisible(_ isShowSheet: Bool) {
        bottomSheetViewDatas.update { $0.isShowSheet = isShowSheet }
    }

    func selectGroup(index: Int) {
        groupViewDatas.update { $0.index = index }
        sheetViewDatas.update { $0.dateOffset = 0 }
    }

    func moveDateOffset(by value: Int) {
        sheetViewDatas.update {
            $0.dateOffset += value
            $0.filter = .all
        }
    }

    func toggleFilter(_ filterType: FilterTypes) {
        let filter = filterType == sheetViewDatas.value.filter ? .all : filterType
        sheetViewDatas.update { $0.filter = filter }
    }

    func makeTodoWriteViewDatas(todos: [TodoEntity]) -> TodoWriteViewDatas {
        TodoWriteViewDatas(
            groupId: currentGroup.id,
            todos: todos.map { WriteTodoEntity(content: $0.content, enabled: false) }
        )
    }

    func makeCertificationViewDatas(index: Int) -> CertificationViewDatas {
        let sheetViewDatas = sheetViewDatas.value
        return CertificationViewDatas(
            title: "내 인증 정보",
            todos: sheetViewDatas.todoList.filter {
                sheetViewDatas.filter == .all || sheetViewDatas.filter == FilterTypes(status: $0.status.rawValue)
            },
            index: index
        )
    }

    func saveLastSelectedGroupIndex(index: Int) async throws {
        try await groupUseCase.saveLastSelectedGroup(groupId: groupViewDatas.value.groups[index].id)
    }
}
