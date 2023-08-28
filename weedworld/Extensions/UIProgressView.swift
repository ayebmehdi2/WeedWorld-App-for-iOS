//
//  UIProgressView.swift
//  weedworld
//
//  Created by Fares Ben amor on 17/1/2023.
//

import Foundation
import UIKit

class CutomProgressView: UIProgressView {
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4.5)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }
    
}
