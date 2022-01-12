//
//  SNTabBarItem.swift
//  SNTabBarDemo-Swift
//
//  Created by ShawnWong on 2022/1/11.
//

import UIKit

class SNTabBarItem: UIButton {
    
    public init(image: UIImage, selectedImage: UIImage) {
        super.init(frame: CGRect.zero)
        
        setImage(image, for: UIControl.State.normal)
        setImage(selectedImage, for: UIControl.State.selected)
        // TODO: deprecated in iOS 15.0
        showsTouchWhenHighlighted = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        // TODO: deprecated in iOS 15.0
        willSet(state) {
            if state {
                self.imageEdgeInsets = UIEdgeInsets.init(top: -49, left: 0, bottom: 0, right: 0)
            }else {
                self.imageEdgeInsets = UIEdgeInsets.zero
            }
        }
    }
}
