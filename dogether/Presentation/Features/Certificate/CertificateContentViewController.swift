//
//  CertificateContentViewController.swift
//  dogether
//
//  Created by seungyooooong on 5/13/25.
//

import UIKit

final class CertificateContentViewController: BaseViewController {
    private let certificateContentPage = CertificateContentPage()
    private let viewModel: CertificateViewModel

    init(viewModel: CertificateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        certificateContentPage.delegate = self
        
        pages = [certificateContentPage]

        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.updateIsFirstResponder(isFirstResponder: true)
    }
    
    override func setViewDatas() {
        if let datas = datas as? CertificateViewDatas {
            viewModel.certificateViewDatas.accept(datas)
        }
        
        bind(viewModel.certificateViewDatas)
        bind(viewModel.certificateTextViewDatas)
        bind(viewModel.certificateButtonViewDatas)
    }
}

@MainActor
protocol CertificateContentDelegate {
    func updateKeyboardHeightAction(height: CGFloat)
    func updateContentAction(content: String)
    func certifyTodoAction()
}

extension CertificateContentViewController: CertificateContentDelegate {
    func updateKeyboardHeightAction(height: CGFloat) {
        viewModel.updateKeyboardHeight(height: height)
        viewModel.updateIsFirstResponder(isFirstResponder: height > 0)
    }
    
    func updateContentAction(content: String) {
        viewModel.updateContent(content: content)
    }
    
    func certifyTodoAction() {
        runTask { [weak self] in
            guard let self else { return }
            try await viewModel.certifyTodo()

            coordinator?.popViewControllers(num: 2)
        }
    }
}
