//
//  BlurEffect.swift
//  weedworld
//
//  Created by Fares Ben amor on 31/1/2023.
//

import Foundation
import UIKit

class BlurEffectView: UIVisualEffectView {
    
    var animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        backgroundColor = .clear
        frame = superview.bounds //Or setup constraints instead
        setupBlur()
    }
    
    private func setupBlur() {
        animator.stopAnimation(true)
        effect = nil
        animator.addAnimations { [weak self] in
            self?.effect = UIBlurEffect(style: .light)
        }
        animator.fractionComplete = 0.1   // This is your blur intensity in range 0 - 1
    }
    
    deinit {
        animator.stopAnimation(true)
    }
}
