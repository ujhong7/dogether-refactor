//
//  GroupManagementPage.swift
//  dogether
//
//  Created by yujaehong on 11/29/25.
//

import UIKit

import RxRelay
import RxSwift

final class GroupManagementPage: BasePage {
    let addGroupTapped = PublishRelay<Void>()
    let leaveGroupTapped = PublishRelay<GroupEntity>()
    private let disposeBag = DisposeBag()
    
    private let navigationHeader = NavigationHeader(title: "그룹 관리")
    private let emptyView = GroupEmptyView()
    private let tableView = UITableView()
    
    private(set) var currentGroups: [GroupEntity]?

    override func configureView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(GroupManagementCell.self, forCellReuseIdentifier: "GroupManagementCell")
    }

    override func configureAction() {
        navigationHeader.delegate = coordinatorDelegate
        
        emptyView.createGroupTapped
            .bind(to: addGroupTapped)
            .disposed(by: disposeBag)

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func configureHierarchy() {
        [navigationHeader, emptyView, tableView].forEach { addSubview($0) }
    }

    override func configureConstraints() {
        navigationHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }

        emptyView.snp.makeConstraints {
            $0.top.equalTo(navigationHeader.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationHeader.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }

    func updateGroupManagement(_ datas: GroupManagementViewDatas) {
        if currentGroups != datas.groups {
            currentGroups = datas.groups

            if datas.groups.isEmpty {
                emptyView.isHidden = false
                tableView.isHidden = true
            } else {
                emptyView.isHidden = true
                tableView.isHidden = false
                tableView.isUserInteractionEnabled = true
                tableView.reloadData()
            }
        }
    }

    override func updateView(_ data: any BaseEntity) {
        guard let datas = data as? GroupManagementViewDatas else { return }
        updateGroupManagement(datas)
    }
}

extension GroupManagementPage: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentGroups?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupManagementCell", for: indexPath) as? GroupManagementCell else { return UITableViewCell() }

        cell.updateView(currentGroups?[indexPath.row])
        cell.leaveTapped
            .bind(to: leaveGroupTapped)
            .disposed(by: cell.disposeBag)

        return cell
    }
}
