//
//  UIViewExt.swift
//  dogether
//
//  Created by seungyooooong on 9/15/25.
//

import UIKit

// associated object 키는 안정적인 저장소가 필요하며, tap action은 메인 액터에서만 접근함
@MainActor
private var UIViewTapActionKey: UInt8 = 0

extension UIView {
    func addTapAction(_ action: @escaping (UITapGestureRecognizer) -> Void) {
        isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapAction(_:)))
        addGestureRecognizer(gesture)
        
        objc_setAssociatedObject(self, &UIViewTapActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func handleTapAction(_ gesture: UITapGestureRecognizer) {
        if let action = objc_getAssociatedObject(self, &UIViewTapActionKey) as? (UITapGestureRecognizer) -> Void {
            action(gesture)
        }
    }
}
