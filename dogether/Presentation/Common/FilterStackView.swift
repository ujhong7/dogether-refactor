//
//  FilterStackView.swift
//  dogether
//
//  Created by seungyooooong on 12/11/25.
//

import Foundation

import RxRelay
import RxSwift

final class FilterStackView: BaseStackView {
    let filterSelected = PublishRelay<FilterTypes>()

    private let allButton = FilterButton(type: .all)
    private let waitButton = FilterButton(type: .wait)
    private let rejectButton = FilterButton(type: .reject)
    private let approveButton = FilterButton(type: .approve)
    private let disposeBag = DisposeBag()
    
    override func configureView() {
        axis = .horizontal
        spacing = 8
    }
    
    override func configureAction() {
        [allButton, waitButton, approveButton, rejectButton].forEach { button in
            button.filterSelected
                .bind(to: filterSelected)
                .disposed(by: disposeBag)
        }
    }
    
    override func configureHierarchy() {
        [allButton, waitButton, approveButton, rejectButton].forEach { addArrangedSubview($0) }
    }
    
    override func configureConstraints() { }
    
    // MARK: - updateView
    override func updateView(_ data: any BaseEntity) {
        if let datas = data as? FilterTypes {
            [allButton, waitButton, rejectButton, approveButton].forEach { $0.updateView(datas) }
        }
    }
}
