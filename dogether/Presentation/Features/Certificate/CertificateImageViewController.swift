//
//  CertificateImageViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/12/25.
//

import UIKit

import RxCocoa
import RxSwift

final class CertificateImageViewController: BaseViewController {
    private let certificateImagePage = CertificateImagePage()
    private let viewModel: CertificateViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: CertificateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        pages = [certificateImagePage]

        super.viewDidLoad()

        bindActions()
    }
    
    override func setViewDatas() {
        if let datas = datas as? CertificateViewDatas {
            viewModel.setDatas(datas)
        }
        
        let output = viewModel.output
        bind(output.certificateViewDatas)
        bind(output.certificateButtonViewDatas)
    }
}

extension CertificateImageViewController {
    private func bindActions() {
        certificateImagePage.nextTapped
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.goCertificateContentView()
            })
            .disposed(by: disposeBag)

        certificateImagePage.permissionDenied
            .asSignal()
            .emit(onNext: { [weak self] type in
                self?.showPermissionPopup(type: type)
            })
            .disposed(by: disposeBag)

        certificateImagePage.pickerRequested
            .asSignal()
            .emit(onNext: { [weak self] pickerController in
                self?.present(pickerController, animated: true)
            })
            .disposed(by: disposeBag)

        certificateImagePage.imageSelected
            .asSignal()
            .emit(onNext: { [weak self] image in
                self?.uploadImage(image)
            })
            .disposed(by: disposeBag)
    }

    private func goCertificateContentView() {
        guard let coordinator else { return }
        coordinator.pushCertificateContent(datas: viewModel.currentDatas)
    }
    
    private func showPermissionPopup(type: AlertTypes) {
        coordinator?.showPopup(type: .alert, alertType: type) { _ in
            SystemManager().openSettingApp()
        }
    }

    private func uploadImage(_ image: UIImage) {
        runTask { [weak self] in
            guard let self else { return }
            viewModel.updateButtonStatus(status: .disabled)

            try await viewModel.uploadImage(image: image)
            viewModel.updateButtonStatus(status: .enabled)
        } catch: { [weak self] _ in
            self?.viewModel.updateButtonStatus(status: .enabled)
        }
    }
}
