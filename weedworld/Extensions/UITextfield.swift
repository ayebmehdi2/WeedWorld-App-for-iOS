//
//  UITextfield.swift
//  weedworld
//
//  Created by Fares Ben amor on 14/1/2023.
//

import Foundation
import UIKit

extension UITextField {
    
    func addBottomLine() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1.0)
        bottomLine.borderColor = UIColor.systemGray4.cgColor
        bottomLine.borderWidth = 1
        borderStyle = .none
        layer.addSublayer(bottomLine)
        layer.masksToBounds = true
    }
    
    func addBottomLineEdit() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: -30, y: frame.height - 1, width: frame.width, height: 1.0)
        bottomLine.borderColor = UIColor.systemGray4.cgColor
        bottomLine.borderWidth = 1
        borderStyle = .none
        layer.addSublayer(bottomLine)
        layer.masksToBounds = false
    }
    
    func addLeftImage(imageName: String) {
        let padding = 18
        let size = 20
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size + padding, height: size))
        let iconView = UIImageView(frame: CGRect(x: 10, y: 0, width: size, height: size))
        iconView.image = UIImage(named: imageName)
        iconView.tintColor = .customGray
        iconView.contentMode = .scaleAspectFit
        outerView.addSubview(iconView)
        leftView = outerView
        leftViewMode = .always
    }

    func addRightImage(imageName: String) {
        let padding = 8
        let size = 17
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size + padding, height: size))
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        iconView.image = UIImage(named: imageName)
        iconView.tintColor = .customGray
        iconView.contentMode = .scaleAspectFit
        outerView.addSubview(iconView)
        rightView = outerView
        rightViewMode = .always
    }
    
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
}
