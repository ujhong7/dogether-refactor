//
//  UpdateViewController.swift
//  dogether
//
//  Created by 승용 on 7/31/25.
//

import RxCocoa
import RxSwift

final class UpdateViewController: BaseViewController {
    private let updatePage = UpdatePage()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        pages = [updatePage]
        
        super.viewDidLoad()

        bindActions()
    }
}

extension UpdateViewController {
    private func bindActions() {
        updatePage.updateTapped
            .asSignal()
            .emit(onNext: {
                SystemManager().openAppStore()
            })
            .disposed(by: disposeBag)
    }
}
