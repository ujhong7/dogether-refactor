//
//  CertificateImageViewController.swift
//  dogether
//
//  Created by seungyooooong on 2/12/25.
//

import UIKit

final class CertificateImageViewController: BaseViewController {
    private let certificateImagePage = CertificateImagePage()
    private let viewModel = CertificateViewModel()
    
    override func viewDidLoad() {
        certificateImagePage.delegate = self
        
        pages = [certificateImagePage]

        super.viewDidLoad()
    }
    
    override func setViewDatas() {
        if let datas = datas as? CertificateViewDatas {
            self.viewModel.certificateViewDatas.accept(datas)
        }
        
        bind(self.viewModel.certificateViewDatas)
        bind(self.viewModel.certificateButtonViewDatas)
    }
}

protocol CertificateImageDelegate {
    func goCertificateContentViewAction()
    func showPopupAction(type: AlertTypes)
    func presentPickerControllerAction(pickerController: UIViewController)
    func uploadImageAction(image: UIImage)
}

extension CertificateImageViewController: CertificateImageDelegate {
    func goCertificateContentViewAction() {
        let certificateContentViewController = CertificateContentViewController()
        let certificateViewDatas = self.viewModel.certificateViewDatas.value
        self.coordinator?.pushViewController(certificateContentViewController, datas: certificateViewDatas)
    }
    
    func showPopupAction(type: AlertTypes) {
        self.coordinator?.showPopup(type: .alert, alertType: type) { _ in
            SystemManager().openSettingApp()
        }
    }
    
    func presentPickerControllerAction(pickerController: UIViewController) {
        self.present(pickerController, animated: true)
    }
    
    func uploadImageAction(image: UIImage) {
        runTask { [self] in
            self.viewModel.updateButtonStatus(status: .disabled)

            try await self.viewModel.uploadImage(image: image)
            self.viewModel.updateButtonStatus(status: .enabled)
        } catch: { [weak self] _ in
            self?.viewModel.updateButtonStatus(status: .enabled)
        }
    }
}
