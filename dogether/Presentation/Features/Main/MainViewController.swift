//
//  MainViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/13/25.
//

import UIKit

import RxCocoa
import RxSwift

final class MainViewController: BaseViewController {
    private let mainPage = MainPage()
    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [mainPage]

        super.viewDidLoad()
        
        onAppear()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadMainView()
        
        coordinator?.setRefreshAction(loadMainView)
    }
    
    override func setViewDatas() {
        let output = viewModel.output
        bind(output.bottomSheetViewDatas, update: mainPage.updateBottomSheet)
        bind(output.groupViewDatas, update: mainPage.updateGroup)
        bind(output.sheetViewDatas, update: mainPage.updateSheet)
        bind(output.timerViewDatas, update: mainPage.updateTimer)
    }
}

extension MainViewController {
    private func onAppear() {
        checkAuthorization()
        getReviews()
        
        coordinator?.handlePendingInviteDeepLink()
    }
    
    private func checkAuthorization() {
        runTask(showLoading: false, retryOnCommonNetworkError: false) { [weak self] in
            guard let self else { return }
            let userNoti = UNUserNotificationCenter.current()
            let settings = await userNoti.notificationSettings()
            
            switch settings.authorizationStatus {
            case .notDetermined:
                try await userNoti.requestAuthorization(options: [.alert, .badge, .sound])
            case .denied:
                coordinator?.showPopup(type: .alert, alertType: .pushNotice) { _ in
                    SystemManager().openSettingApp()
                }
            default:    // MARK: .authorized, .provisional, .ephemeral
                break
            }
        }
    }
    
    private func getReviews() {
        // ???: 화면 전환을 고려하면 일부러 강한 참조를 걸어야할까
        runTask { [weak self] in
            guard let self else { return }
            let reviews = try await viewModel.getReviews()
            if reviews.isEmpty { return }

            coordinator?.showModal(reviews: reviews)
        }
    }
    
    private func loadMainView() {
        runTask { [weak self] in
            guard let self else { return }
            let isEmptyGroups = try await viewModel.loadGroups()
            
            if isEmptyGroups {
                guard let coordinator else { return }
                coordinator.setStart()
                return
            }
            
            try await viewModel.setSheetViewDatasForCurrentGroup()
        }
    }

    private func bindActions() {
        mainPage.sheetAlphaChanged
            .asSignal()
            .emit(onNext: { [weak self] alpha in
                self?.viewModel.updateSheetAlpha(alpha)
            })
            .disposed(by: disposeBag)

        mainPage.sheetStatusChanged
            .asSignal()
            .emit(onNext: { [weak self] sheetStatus in
                self?.viewModel.updateSheetStatus(sheetStatus)
            })
            .disposed(by: disposeBag)

        mainPage.sheetYOffsetChanged
            .asSignal()
            .emit(onNext: { [weak self] yOffset in
                self?.viewModel.updateSheetYOffset(yOffset)
            })
            .disposed(by: disposeBag)

        mainPage.isScrollOnTopChanged
            .asSignal()
            .emit(onNext: { [weak self] isScrollOnTop in
                self?.viewModel.updateIsScrollOnTop(isScrollOnTop)
            })
            .disposed(by: disposeBag)

        mainPage.rankingTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.goRankingView()
            })
            .disposed(by: disposeBag)

        mainPage.bottomSheetVisibleChanged
            .asSignal()
            .emit(onNext: { [weak self] isShowSheet in
                self?.viewModel.updateBottomSheetVisible(isShowSheet)
            })
            .disposed(by: disposeBag)

        mainPage.groupSelected
            .asSignal()
            .emit(onNext: { [weak self] index in
                self?.selectGroup(index: index)
            })
            .disposed(by: disposeBag)

        mainPage.addGroupTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.addGroup()
            })
            .disposed(by: disposeBag)

        mainPage.inviteTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.invite()
            })
            .disposed(by: disposeBag)

        mainPage.pastTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.goPast()
            })
            .disposed(by: disposeBag)

        mainPage.futureTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.goFuture()
            })
            .disposed(by: disposeBag)

        mainPage.timerShouldStart
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.viewModel.startTimer()
            })
            .disposed(by: disposeBag)

        mainPage.timerShouldStop
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.viewModel.stopTimer()
            })
            .disposed(by: disposeBag)

        mainPage.writeTodoRequested
            .asSignal()
            .emit(onNext: { [weak self] todos in
                self?.goWriteTodoView(todos: todos)
            })
            .disposed(by: disposeBag)

        mainPage.filterSelected
            .asSignal()
            .emit(onNext: { [weak self] filterType in
                self?.viewModel.toggleFilter(filterType)
            })
            .disposed(by: disposeBag)

        mainPage.certificateImageRequested
            .asSignal()
            .emit(onNext: { [weak self] todo in
                self?.goCertificateView(todo: todo)
            })
            .disposed(by: disposeBag)

        mainPage.certificationRequested
            .asSignal()
            .emit(onNext: { [weak self] index in
                self?.goCertificationView(index: index)
            })
            .disposed(by: disposeBag)
    }

    private func goRankingView() {
        guard let coordinator else { return }
        let rankingViewDatas = RankingViewDatas(groupId: viewModel.currentGroup.id)
        coordinator.pushRanking(datas: rankingViewDatas)
    }

    private func selectGroup(index: Int) {
        viewModel.selectGroup(index: index)

        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.saveLastSelectedGroupIndex(index: index)
            try await viewModel.setSheetViewDatasForCurrentGroup()
        }
    }

    private func addGroup() {
        guard let coordinator else { return }
        let startViewDatas = StartViewDatas(isFirstGroup: false)
        coordinator.pushStart(datas: startViewDatas)
    }

    private func invite() {
        let group = viewModel.currentGroup

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

    private func goPast() {
        viewModel.moveDateOffset(by: -1)

        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.setSheetViewDatasForCurrentGroup()
        }
    }

    private func goFuture() {
        viewModel.moveDateOffset(by: 1)

        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.setSheetViewDatasForCurrentGroup()
        }
    }

    private func goWriteTodoView(todos: [TodoEntity]) {
        guard let coordinator else { return }
        coordinator.pushTodoWrite(datas: viewModel.makeTodoWriteViewDatas(todos: todos))
    }

    private func goCertificateView(todo: TodoEntity) {
        guard let coordinator else { return }
        let certificateViewDatas = CertificateViewDatas(todo: todo)
        coordinator.pushCertificateImage(datas: certificateViewDatas)
    }

    private func goCertificationView(index: Int) {
        guard let coordinator else { return }
        coordinator.pushCertification(datas: viewModel.makeCertificationViewDatas(index: index))
    }
}
