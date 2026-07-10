//
//  MainPage.swift
//  dogether
//
//  Created by seungyooooong on 8/26/25.
//

import UIKit

import RxRelay
import RxSwift
import SnapKit

final class MainPage: BasePage {
    let sheetAlphaChanged = PublishRelay<CGFloat>()
    let sheetStatusChanged = PublishRelay<SheetStatus>()
    let sheetYOffsetChanged = PublishRelay<CGFloat>()
    let isScrollOnTopChanged = PublishRelay<Bool>()
    let rankingTapped = PublishRelay<Void>()
    let bottomSheetVisibleChanged = PublishRelay<Bool>()
    let groupSelected = PublishRelay<Int>()
    let addGroupTapped = PublishRelay<Void>()
    let inviteTapped = PublishRelay<Void>()
    let pastTapped = PublishRelay<Void>()
    let futureTapped = PublishRelay<Void>()
    let timerShouldStart = PublishRelay<Void>()
    let timerShouldStop = PublishRelay<Void>()
    let writeTodoRequested = PublishRelay<[TodoEntity]>()
    let filterSelected = PublishRelay<FilterTypes>()
    let certificateImageRequested = PublishRelay<TodoEntity>()
    let certificationRequested = PublishRelay<Int>()
    
    private let dogetherHeader = DogetherHeader()
    
    private let dosikCommentButton = DosikCommentButton()
    private let bottomSheetView = BottomSheetView()
    
    private let groupInfoView = GroupInfoView(type: .main)
    private let rankingButton = RankingButton()
    
    private let dogetherSheet = UIView()
    
    private let sheetHeaderView = SheetHeaderView()
    
    private let timerView = TimerView()
    private let todoListView = TodoListView()
    private let todayEmptyView = TodayEmptyView()
    private let pastEmptyView = PastEmptyView()
    private let doneView = DoneView()
    private let disposeBag = DisposeBag()
    
    private(set) var currentSheetStatus: SheetStatus?
    private(set) var currentYOffset: CGFloat?
    private(set) var currentIsScrollOnTop: Bool?
    
    override func configureView() {
        dogetherSheet.backgroundColor = .grey800
        dogetherSheet.layer.cornerRadius = 32
        dogetherSheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        dogetherSheet.isUserInteractionEnabled = true
        
        [timerView, todoListView, todayEmptyView, pastEmptyView, doneView].forEach { $0.isHidden = true }
    }
    
    override func configureAction() {
        dogetherHeader.delegate = coordinatorDelegate

        bottomSheetView.isVisibleChanged
            .bind(to: bottomSheetVisibleChanged)
            .disposed(by: disposeBag)

        bottomSheetView.itemSelected
            .bind(to: groupSelected)
            .disposed(by: disposeBag)

        bottomSheetView.addGroupTapped
            .bind(to: addGroupTapped)
            .disposed(by: disposeBag)

        groupInfoView.groupSelectionTapped
            .map { true }
            .bind(to: bottomSheetVisibleChanged)
            .disposed(by: disposeBag)

        groupInfoView.inviteTapped
            .bind(to: inviteTapped)
            .disposed(by: disposeBag)

        rankingButton.rankingTapped
            .bind(to: rankingTapped)
            .disposed(by: disposeBag)

        sheetHeaderView.pastTapped
            .bind(to: pastTapped)
            .disposed(by: disposeBag)

        sheetHeaderView.futureTapped
            .bind(to: futureTapped)
            .disposed(by: disposeBag)

        todayEmptyView.writeTodoTapped
            .map { [] }
            .bind(to: writeTodoRequested)
            .disposed(by: disposeBag)

        todoListView.filterSelected
            .bind(to: filterSelected)
            .disposed(by: disposeBag)

        todoListView.writeTodoRequested
            .bind(to: writeTodoRequested)
            .disposed(by: disposeBag)

        todoListView.certificateImageRequested
            .bind(to: certificateImageRequested)
            .disposed(by: disposeBag)

        todoListView.certificationRequested
            .bind(to: certificationRequested)
            .disposed(by: disposeBag)

        todoListView.isScrollOnTopChanged
            .bind(to: isScrollOnTopChanged)
            .disposed(by: disposeBag)
        
        let dogetherPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        dogetherPanGesture.delegate = self
        dogetherSheet.addGestureRecognizer(dogetherPanGesture)
    }
    
    override func configureHierarchy() {
        [dogetherHeader, groupInfoView, dosikCommentButton,
         rankingButton, dogetherSheet, bottomSheetView].forEach { addSubview($0) }
        
        [sheetHeaderView, timerView, todoListView, todayEmptyView, pastEmptyView, doneView].forEach { dogetherSheet.addSubview($0) }
    }
    
    override func configureConstraints() {
        dogetherHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        groupInfoView.snp.makeConstraints {
            $0.top.equalTo(dogetherHeader.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(143)
        }
        
        dosikCommentButton.snp.makeConstraints {
            $0.bottom.equalTo(groupInfoView.snp.top).offset(-6)
            $0.right.equalTo(groupInfoView)
        }
        
        rankingButton.snp.makeConstraints {
            $0.top.equalTo(groupInfoView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        dogetherSheet.snp.makeConstraints {
            $0.top.equalToSuperview().offset(SheetViewDatas().sheetStatus.offset)
            $0.bottom.equalToSuperview().offset(UIApplication.safeAreaOffset.bottom)
            $0.left.right.equalToSuperview()
        }
        
        sheetHeaderView.snp.makeConstraints {
            $0.top.equalTo(dogetherSheet).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }
        
        [timerView, todoListView, todayEmptyView, pastEmptyView, doneView].forEach {
            $0.snp.makeConstraints {
                $0.top.equalTo(sheetHeaderView.snp.bottom)
                $0.bottom.equalToSuperview().inset(UIApplication.safeAreaOffset.bottom)
                $0.horizontalEdges.equalToSuperview()
            }
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - updateView
    override func updateView(_ data: (any BaseEntity)?) {
        if let datas = data as? BottomSheetViewDatas {
            bottomSheetView.updateView(datas)
        }
        
        if let datas = data as? GroupViewDatas, datas.groups.count > 0 {
            bottomSheetView.updateView(datas)
            groupInfoView.updateView(datas.groups[datas.index])
            dosikCommentButton.updateView(datas.groups[datas.index])
            sheetHeaderView.updateView(datas)
        }
        
        if let datas = data as? SheetViewDatas {
            if currentIsScrollOnTop != datas.isScrollOnTop {
                currentIsScrollOnTop = datas.isScrollOnTop
            }
            
            groupInfoView.updateView(datas)
            rankingButton.updateView(datas)
            sheetHeaderView.updateView(datas)
            
            timerView.isHidden = !(datas.status == .timer)
            todoListView.isHidden = !(datas.status == .certificateTodo || datas.status == .todoList)
            todayEmptyView.isHidden = !(datas.status == .createTodo)
            pastEmptyView.isHidden = !(datas.status == .emptyList)
            doneView.isHidden = !(datas.status == .done)
            
            if datas.status == .timer {
                timerShouldStart.accept(())
            } else {
                timerShouldStop.accept(())
            }
            
            if datas.status == .certificateTodo || datas.status == .todoList {
                todoListView.updateView(datas)
            }
            
            if datas.status == .createTodo {
                todayEmptyView.updateView(datas)
            }
            
            if currentYOffset == datas.yOffset && currentSheetStatus == datas.sheetStatus { return }
            currentYOffset = datas.yOffset
            currentSheetStatus = datas.sheetStatus
            
            dogetherSheet.snp.updateConstraints {
                $0.top.equalToSuperview().offset(datas.yOffset)
            }
        }
        
        if let datas = data as? TimerViewDatas {
            timerView.updateView(datas)
        }
    }
}

// MARK: - about pan gesture
extension MainPage: UIGestureRecognizerDelegate {
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .changed:
            guard let newOffset = getNewOffset(from: currentYOffset, with: translation.y) else { return }
            sheetYOffsetChanged.accept(newOffset)
            sheetAlphaChanged.accept(
                1 - (SheetStatus.normal.offset - newOffset) / (SheetStatus.normal.offset - SheetStatus.expand.offset)
            )
            layoutIfNeeded()

        case .ended:
            guard let status = getNewStatus(with: translation.y) else { return }
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                sheetAlphaChanged.accept(status == .normal ? 1 : 0)
                sheetStatusChanged.accept(status)
                sheetYOffsetChanged.accept(status.offset)
                layoutIfNeeded()
            }

        default:
            break
        }
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let currentIsScrollOnTop, !currentIsScrollOnTop && currentSheetStatus == .expand { return false }
        return true
    }
}

// MARK: - about sheet
extension MainPage {
    private func getNewOffset(from currentOffset: CGFloat?, with translation: CGFloat) -> CGFloat? {
        guard let currentSheetStatus else { return nil }
        switch currentSheetStatus {
        case .expand:
            if translation > 0 { return min(SheetStatus.normal.offset, SheetStatus.expand.offset + translation) }
            return currentOffset
        case .normal:
            if translation < 0 { return max(0, SheetStatus.normal.offset + translation) }
            return currentOffset
        }
    }
    
    private func getNewStatus(with translation: CGFloat) -> SheetStatus? {
        guard let currentSheetStatus else { return nil }
        switch currentSheetStatus {
        case .expand:
            return translation > 100 ? .normal : .expand
        case .normal:
            return translation < -100 ? .expand : .normal
        }
    }
}
