//
//  CertificationListView.swift
//  dogether
//
//  Created by seungyooooong on 10/22/25.
//

import UIKit

import RxRelay

final class CertificationListView: BaseView {
    let indexSelected = PublishRelay<Int>()
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private var isFirst: Bool = true
    private var currentIndex: Int?
    
    override func configureView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
    
        stackView.axis = .horizontal
        stackView.spacing = 32
        stackView.distribution = .fillEqually
    }
    
    override func configureAction() {
        scrollView.delegate = self

        stackView.addTapAction { [weak self] gesture in
            guard let self else { return }
            let location = gesture.location(in: scrollView)
            let scrollViewWidth = scrollView.bounds.width
            let direction: Directions = location.x - scrollView.contentOffset.x < scrollViewWidth / 2 ? .prev : .next
            let index = Int(round(scrollView.contentOffset.x / scrollViewWidth))
            let nextIndex = index + direction.tag

            if nextIndex < 0 || stackView.arrangedSubviews.count <= nextIndex { return }

            let newOffset = CGPoint(x: scrollViewWidth * CGFloat(nextIndex), y: 0)
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.setContentOffset(newOffset, animated: false)
            }, completion: { [weak self] finished in
                if finished {
                    self?.indexSelected.accept(nextIndex)
                }
            })
        }
    }
    
    override func configureHierarchy() {
        [scrollView].forEach { addSubview($0) }
        [stackView].forEach { scrollView.addSubview($0) }
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - updateView
    override func updateView(_ data: (any BaseEntity)?) {
        if let datas = data as? CertificationViewDatas {
            if isFirst {
                isFirst = false
                
                layoutIfNeeded()
                
                datas.todos
                    .map {
                        if let mediaUrl = $0.certificationMediaUrl {
                            let viewDatas = CertificationImageViewDatas(
                                imageUrl: mediaUrl,
                                content: $0.certificationContent
                            )
                            let imageView = CertificationImageView(type: .embarrassed)
                            imageView.updateView(viewDatas)
                            return imageView
                        } else {
                            return CertificationImageView(type: .embarrassed)
                        }
                    }
                    .forEach {
                        stackView.addArrangedSubview($0)
                    }
                
                stackView.snp.makeConstraints {
                    $0.horizontalEdges.equalToSuperview().inset(16)
                    $0.width.equalTo(frame.width * CGFloat(datas.todos.count) - 32)
                    $0.height.equalToSuperview()
                }
            }
            
            if currentIndex != datas.index {
                currentIndex = datas.index
                
                let scrollViewWidth = scrollView.bounds.width
                let newOffset = CGPoint(x: scrollViewWidth * CGFloat(datas.index), y: 0)
                scrollView.setContentOffset(newOffset, animated: false)
            }
        }
    }
}

extension CertificationListView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / frame.width))
        indexSelected.accept(index)
    }
}
