//
//  CertificationViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/16/25.
//

import UIKit

import RxCocoa
import RxSwift

final class CertificationViewController: BaseViewController {
    private let certificationPage = CertificationPage()
    private let viewModel: CertificationViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: CertificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [certificationPage]

        super.viewDidLoad()
        
        onAppear()
        bindActions()
    }
    
    override func setViewDatas() {
        if let datas = datas as? CertificationViewDatas {
            viewModel.setDatas(datas)
        }
        
        let output = viewModel.output
        bind(output.certificationViewDatas)
    }
}

extension CertificationViewController {
    private func onAppear() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.readTodo()
        }
    }

    private func bindActions() {
        certificationPage.indexSelected
            .asSignal()
            .emit(onNext: { [weak self] index in
                self?.updateIndex(index)
            })
            .disposed(by: disposeBag)
    }

    private func updateIndex(_ index: Int) {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.setIndex(index: index)
        }
    }
}
