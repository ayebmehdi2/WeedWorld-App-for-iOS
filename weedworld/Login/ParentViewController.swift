//
//  LoginViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 12/1/2023.
//

import UIKit

class ParentViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signUpContainerView: UIView!
    @IBOutlet weak var signUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var loginViewHeight: NSLayoutConstraint!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginContainerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        customSegmentedControl()
    }
    
    func setupUI() {
        signUpView.backgroundColor = .customGreen
        loginView.backgroundColor = .customGreen
        signUpView.layer.cornerRadius = signUpView.frame.height / 2
    }
    
    func customSegmentedControl() {
        segmentedControl.backgroundColor = .clear
        segmentedControl.setTitle("Sign up", forSegmentAt: 0)
        segmentedControl.setTitle("Log in", forSegmentAt: 1)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.white    ], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 18)!], for: .selected)
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    @IBAction func segmentedClick(_ sender: UISegmentedControl) {
        view.endEditing(true) // Hide keyboard
        
        if sender.selectedSegmentIndex == 0 {
            signUpViewHeight.constant = 6
            loginViewHeight.constant = 1
            view.bringSubviewToFront(signUpContainerView)
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
        else {
            loginViewHeight.constant = 6
            signUpViewHeight.constant = 1
            view.bringSubviewToFront(loginContainerView)
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
                self.loginView.layer.cornerRadius = self.loginView.frame.height / 2
            })
        }
    }
}
