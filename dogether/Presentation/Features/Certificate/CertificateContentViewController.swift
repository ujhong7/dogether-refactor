//
//  CertificateContentViewController.swift
//  dogether
//
//  Created by seungyooooong on 5/13/25.
//

import UIKit

final class CertificateContentViewController: BaseViewController {
    private let certificateContentPage = CertificateContentPage()
    private let viewModel = CertificateViewModel()
    
    override func viewDidLoad() {
        certificateContentPage.delegate = self
        
        pages = [certificateContentPage]

        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewModel.updateIsFirstResponder(isFirstResponder: true)
    }
    
    override func setViewDatas() {
        if let datas = datas as? CertificateViewDatas {
            self.viewModel.certificateViewDatas.accept(datas)
        }
        
        bind(self.viewModel.certificateViewDatas)
        bind(self.viewModel.certificateTextViewDatas)
        bind(self.viewModel.certificateButtonViewDatas)
    }
}

protocol CertificateContentDelegate {
    func updateKeyboardHeightAction(height: CGFloat)
    func updateContentAction(content: String)
    func certifyTodoAction()
}

extension CertificateContentViewController: CertificateContentDelegate {
    func updateKeyboardHeightAction(height: CGFloat) {
        self.viewModel.updateKeyboardHeight(height: height)
        self.viewModel.updateIsFirstResponder(isFirstResponder: height > 0)
    }
    
    func updateContentAction(content: String) {
        self.viewModel.updateContent(content: content)
    }
    
    func certifyTodoAction() {
        runTask { [self] in
            try await self.viewModel.certifyTodo()

            self.coordinator?.popViewControllers(num: 2)
        }
    }
}
