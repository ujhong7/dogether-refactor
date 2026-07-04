//
//  MainViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/13/25.
//

import UIKit

final class MainViewController: BaseViewController {
    private let mainPage = MainPage()
    private let viewModel = MainViewModel()
    
    override func viewDidLoad() {
        mainPage.delegate = self
        
        pages = [mainPage]

        super.viewDidLoad()
        
        onAppear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadMainView()
        
        self.coordinator?.updateViewController = loadMainView
    }
    
    override func setViewDatas() {
        bind(self.viewModel.bottomSheetViewDatas)
        bind(self.viewModel.groupViewDatas)
        bind(self.viewModel.sheetViewDatas)
        bind(self.viewModel.timerViewDatas)
    }
}

extension MainViewController {
    private func onAppear() {
        checkAuthorization()
        getReviews()
        
        if let code = DeepLinkManager.shared.consumeInviteCode() {
            let groupJoinViewController = GroupJoinViewController()
            let groupJoinViewDatas = GroupJoinViewDatas(code: code)
            self.coordinator?.pushViewController(groupJoinViewController, datas: groupJoinViewDatas)
        }
    }
    
    private func checkAuthorization() {
        runTask(showLoading: false, retryOnCommonNetworkError: false) { [self] in
            let userNoti = UNUserNotificationCenter.current()
            let settings = await userNoti.notificationSettings()
            
            switch settings.authorizationStatus {
            case .notDetermined:
                try await userNoti.requestAuthorization(options: [.alert, .badge, .sound])
            case .denied:
                self.coordinator?.showPopup(type: .alert, alertType: .pushNotice) { _ in
                    SystemManager().openSettingApp()
                }
            default:    // MARK: .authorized, .provisional, .ephemeral
                break
            }
        }
    }
    
    private func getReviews() {
        // ???: 화면 전환을 고려하면 일부러 강한 참조를 걸어야할까
        runTask { [self] in
            let reviews = try await self.viewModel.getReviews()
            if reviews.isEmpty { return }

            self.coordinator?.showModal(reviews: reviews)
        }
    }
    
    private func loadMainView() {
        runTask { [self] in
            let groupViewDatas = try await self.viewModel.getGroups()
            self.viewModel.groupViewDatas.accept(groupViewDatas)
            
            if groupViewDatas.groups.isEmpty {
                self.coordinator?.setNavigationController(StartViewController())
                return
            }
            
            try await self.viewModel.setSheetViewDatasForCurrentGroup()
        }
    }
}

// MARK: - delegate
protocol MainDelegate {
    func updateAlphaBySheet(alpha: CGFloat)
    func updateSheetStatus(sheetStatus: SheetStatus)
    func updateYOffsetOfSheet(yOffset: CGFloat)
    func updateIsScrollOnTop(isScrollOnTop: Bool)
    func goRankingViewAction()
    func updateBottomSheetVisibleAction(isShowSheet: Bool)
    func selectGroupAction(index: Int)
    func addGroupAction()
    func inviteAction()
    func goPastAction()
    func goFutureAction()
    func startTimerAction()
    func stopTimerAction()
    func goWriteTodoViewAction(todos: [TodoEntity])
    func selectFilterAction(filterType: FilterTypes)
    func goCertificateViewAction(todo: TodoEntity)
    func goCertificationViewAction(index: Int)
}

extension MainViewController: MainDelegate {
    func updateAlphaBySheet(alpha: CGFloat) {
        self.viewModel.sheetViewDatas.update { $0.alpha = alpha }
    }
    
    func updateSheetStatus(sheetStatus: SheetStatus) {
        self.viewModel.sheetViewDatas.update { $0.sheetStatus = sheetStatus }
    }
    
    func updateYOffsetOfSheet(yOffset: CGFloat) {
        self.viewModel.sheetViewDatas.update { $0.yOffset = yOffset }
    }
    
    func updateIsScrollOnTop(isScrollOnTop: Bool) {
        self.viewModel.sheetViewDatas.update { $0.isScrollOnTop = isScrollOnTop }
    }
    
    func goRankingViewAction() {
        let rankingViewController = RankingViewController()
        let rankingViewDatas = RankingViewDatas(groupId: self.viewModel.currentGroup.id)
        self.coordinator?.pushViewController(rankingViewController, datas: rankingViewDatas)
    }
    
    func updateBottomSheetVisibleAction(isShowSheet: Bool) {
        self.viewModel.bottomSheetViewDatas.update { $0.isShowSheet = isShowSheet }
    }
    
    func selectGroupAction(index: Int) {
        self.viewModel.groupViewDatas.update { $0.index = index }
        
        self.viewModel.sheetViewDatas.update { $0.dateOffset = 0 }

        runTask { [self] in
            try await self.viewModel.saveLastSelectedGroupIndex(index: index)
            try await self.viewModel.setSheetViewDatasForCurrentGroup()
        }
    }
    
    func addGroupAction() {
        let startViewController = StartViewController()
        let startViewDatas = StartViewDatas(isFirstGroup: false)
        self.coordinator?.pushViewController(startViewController, datas: startViewDatas)
    }
    
    func inviteAction() {
        let group = self.viewModel.currentGroup

        runTask {
            try await SystemManager.inviteGroup(
                groupName: group.name,
                joinCode: group.joinCode
            )
        } success: { [weak self] inviteItems in
            let activityVC = UIActivityViewController(
                activityItems: inviteItems,
                applicationActivities: nil
            )
            self?.present(activityVC, animated: true)
        }
    }
    
    func goPastAction() {
        self.viewModel.sheetViewDatas.update {
            $0.dateOffset -= 1
            $0.filter = .all
        }

        runTask { [self] in
            try await self.viewModel.setSheetViewDatasForCurrentGroup()
        }
    }
    
    func goFutureAction() {
        self.viewModel.sheetViewDatas.update {
            $0.dateOffset += 1
            $0.filter = .all
        }

        runTask { [self] in
            try await self.viewModel.setSheetViewDatasForCurrentGroup()
        }
    }
    
    func startTimerAction() {
        self.viewModel.startTimer()
    }
    
    func stopTimerAction() {
        self.viewModel.stopTimer()
    }
    
    func goWriteTodoViewAction(todos: [TodoEntity]) {
        let todoWriteViewController = TodoWriteViewController()
        let todoWriteViewDatas = TodoWriteViewDatas(
            groupId: self.viewModel.currentGroup.id,
            todos: todos.map { WriteTodoEntity(content: $0.content, enabled: false) }
        )
        self.coordinator?.pushViewController(todoWriteViewController, datas: todoWriteViewDatas)
    }
    
    func selectFilterAction(filterType: FilterTypes) {
        let filter = filterType == self.viewModel.sheetViewDatas.value.filter ? .all : filterType
        self.viewModel.sheetViewDatas.update { $0.filter = filter }
    }
    
    func goCertificateViewAction(todo: TodoEntity) {
        let certificateImageViewController = CertificateImageViewController()
        let certificateViewDatas = CertificateViewDatas(todo: todo)
        self.coordinator?.pushViewController(certificateImageViewController, datas: certificateViewDatas)
    }
    
    func goCertificationViewAction(index: Int) {
        let certificationViewController = CertificationViewController()
        let certificationViewDatas = CertificationViewDatas(
            title: "내 인증 정보",
            todos: self.viewModel.sheetViewDatas.value.todoList.filter {
                self.viewModel.sheetViewDatas.value.filter == .all || self.viewModel.sheetViewDatas.value.filter == FilterTypes(status: $0.status.rawValue)
            },
            index: index
        )
        self.coordinator?.pushViewController(certificationViewController, datas: certificationViewDatas)
    }
}
