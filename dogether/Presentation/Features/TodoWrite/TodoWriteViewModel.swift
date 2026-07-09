//
//  TodoWriteViewModel.swift
//  dogether
//
//  Created by seungyooooong on 3/30/25.
//

import Foundation

import RxCocoa
import RxRelay
import RxSwift

@MainActor
final class TodoWriteViewModel {
    struct Input {
        let viewDidAppear: Signal<Void>
        let todoChanged: Signal<String>
        let addTapped: Signal<Void>
        let removeTapped: Signal<Int>
        let keyboardVisibleChanged: Signal<Bool>
    }

    struct Output {
        let todoWriteViewDatas: Driver<TodoWriteViewDatas>
    }

    private let challengeGroupsUseCase: ChallengeGroupUseCase
    private let disposeBag = DisposeBag()
    
    private let todoWriteViewDatas = BehaviorRelay<TodoWriteViewDatas>(value: TodoWriteViewDatas())
    
    init(challengeGroupsUseCase: ChallengeGroupUseCase) {
        self.challengeGroupsUseCase = challengeGroupsUseCase
    }

    func transform(input: Input) -> Output {
        input.viewDidAppear
            .emit(onNext: { [weak self] in
                self?.updateIsFirstResponder(isFirstResponder: true)
            })
            .disposed(by: disposeBag)

        input.todoChanged
            .emit(onNext: { [weak self] todo in
                self?.updateTodo(todo: todo)
            })
            .disposed(by: disposeBag)

        input.addTapped
            .emit(onNext: { [weak self] in
                self?.addTodo()
            })
            .disposed(by: disposeBag)

        input.removeTapped
            .emit(onNext: { [weak self] index in
                self?.removeTodo(index: index)
            })
            .disposed(by: disposeBag)

        input.keyboardVisibleChanged
            .emit(onNext: { [weak self] isShowKeyboard in
                self?.updateIsShowKeyboard(isShowKeyboard: isShowKeyboard)
            })
            .disposed(by: disposeBag)

        return Output(todoWriteViewDatas: todoWriteViewDatas.asDriver())
    }

    func setDatas(_ datas: TodoWriteViewDatas) {
        todoWriteViewDatas.accept(datas)
    }
}

extension TodoWriteViewModel {
    func updateIsFirstResponder(isFirstResponder: Bool) {
        todoWriteViewDatas.update { $0.isFirstResponder = isFirstResponder }
    }
    
    func updateIsShowKeyboard(isShowKeyboard: Bool) {
        todoWriteViewDatas.update { $0.isShowKeyboard = isShowKeyboard }
    }
    
    func updateTodo(todo: String) {
        todoWriteViewDatas.update { $0.todo = todo }
    }
    
    func addTodo(todoMaxCount: Int = 10) {
        let todo = todoWriteViewDatas.value.todo
        let todos = todoWriteViewDatas.value.todos
        if todo.isEmpty || todos.count >= todoMaxCount { return }

        todoWriteViewDatas.update {
            $0.todo = ""
            $0.todos = [WriteTodoEntity(content: todo)] + todos
            $0.isShowKeyboard = false
        }
    }
    
    func removeTodo(index: Int) {
        var todos = todoWriteViewDatas.value.todos
        guard index < todos.count else { return }

        todos.remove(at: index)
        todoWriteViewDatas.update { $0.todos = todos }
    }
    
    func createTodos() async throws {
        try await challengeGroupsUseCase.createTodos(
            groupId: todoWriteViewDatas.value.groupId,
            todos: todoWriteViewDatas.value.todos
        )
    }
}
