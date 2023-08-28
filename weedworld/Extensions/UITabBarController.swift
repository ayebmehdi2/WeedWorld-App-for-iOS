//
//  UITabBarController.swift
//  weedworld
//
//  Created by Fares Ben amor on 15/1/2023.
//

import Foundation
import UIKit

class CustomTabBar: UITabBarController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.layer.masksToBounds = true
        //tabBar.layer.cornerRadius = 20
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.frame.size.height = 100
        tabBar.frame.origin.y = view.frame.height - 100
    }
}
