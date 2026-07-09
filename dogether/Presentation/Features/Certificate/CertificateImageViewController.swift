//
//  CertificateImageViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/12/25.
//

import UIKit

final class CertificateImageViewController: BaseViewController {
    private let certificateImagePage = CertificateImagePage()
    private let viewModel: CertificateViewModel

    init(viewModel: CertificateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        certificateImagePage.delegate = self
        
        pages = [certificateImagePage]

        super.viewDidLoad()
    }
    
    override func setViewDatas() {
        if let datas = datas as? CertificateViewDatas {
            viewModel.certificateViewDatas.accept(datas)
        }
        
        bind(viewModel.certificateViewDatas)
        bind(viewModel.certificateButtonViewDatas)
    }
}

@MainActor
protocol CertificateImageDelegate {
    func goCertificateContentViewAction()
    func showPopupAction(type: AlertTypes)
    func presentPickerControllerAction(pickerController: UIViewController)
    func uploadImageAction(image: UIImage)
}

extension CertificateImageViewController: CertificateImageDelegate {
    func goCertificateContentViewAction() {
        guard let coordinator else { return }
        let certificateViewDatas = viewModel.certificateViewDatas.value
        coordinator.pushCertificateContent(datas: certificateViewDatas)
    }
    
    func showPopupAction(type: AlertTypes) {
        coordinator?.showPopup(type: .alert, alertType: type) { _ in
            SystemManager().openSettingApp()
        }
    }
    
    func presentPickerControllerAction(pickerController: UIViewController) {
        present(pickerController, animated: true)
    }
    
    func uploadImageAction(image: UIImage) {
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
