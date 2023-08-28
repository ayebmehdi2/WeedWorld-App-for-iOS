//
//  UIViewcontroller.swift
//  weedworld
//
//  Created by Fares Ben amor on 14/1/2023.
//

import Foundation
import UIKit
import SideMenu

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showSpinnerInsideButton(sender: UIButton, activityIndicator: UIActivityIndicatorView) {
        activityIndicator.color = .systemBackground
        activityIndicator.style = .medium
        sender.setTitle("", for: .normal)
        sender.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: sender.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: sender.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    func stopSpinner(sender: UIButton, activityIndicator: UIActivityIndicatorView, buttonTitle: String) {
        activityIndicator.removeFromSuperview()
        sender.setTitle(buttonTitle, for: .normal)
    }
    
    func showActivityIndicator(view: UIView, activityIndicator: UIActivityIndicatorView) {
        activityIndicator.color = .customGreen
        activityIndicator.style = .large
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
    }
    
    func showSideMenu() {
        let storyBoard = UIStoryboard(name: "SideMenu", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuNavigationController
        vc.presentationStyle = .menuSlideIn
        vc.presentationStyle.presentingEndAlpha = 0.5
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        present(vc, animated: true)
    }
}
