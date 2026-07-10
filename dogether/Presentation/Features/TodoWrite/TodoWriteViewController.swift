//
//  TodoWriteViewController.swift
//  dogether
//
//  Created by seungyooooong on 3/30/25.
//

import UIKit

import RxCocoa
import RxRelay
import RxSwift

final class TodoWriteViewController: BaseViewController {
    private let todoWritePage = TodoWritePage()
    private let viewModel: TodoWriteViewModel
    private let viewDidAppearRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    init(viewModel: TodoWriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [todoWritePage]
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearRelay.accept(())
    }
    
    override func setViewDatas() {
        if let datas = datas as? TodoWriteViewDatas {
            viewModel.setDatas(datas)
        }
        
        let input = TodoWriteViewModel.Input(
            viewDidAppear: viewDidAppearRelay.asSignal(),
            todoChanged: todoWritePage.todoChanged.asSignal(),
            addTapped: todoWritePage.addTapped.asSignal(),
            removeTapped: todoWritePage.removeTapped.asSignal(),
            keyboardVisibleChanged: todoWritePage.keyboardVisibleChanged.asSignal()
        )
        let output = viewModel.transform(input: input)
        bind(output.todoWriteViewDatas)

        todoWritePage.saveTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.saveTodo()
            })
            .disposed(by: disposeBag)
    }
}

extension TodoWriteViewController {
    private func saveTodo() {
        coordinator?.showPopup(type: .alert, alertType: .saveTodo) { [weak self] _ in
            guard let self else { return }
            runTask { [weak self] in
                guard let self else { return }
                try await viewModel.createTodos()
                coordinator?.popViewController()
            }
        }
    }
}
