//
//  LoginViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 14/1/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var loginBtn: UIButton! {
        didSet {
            loginBtn.layer.cornerRadius = loginBtn.frame.height / 2
        }
    }
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
    }
    
    func setupUI() {
        
        // UsernameTF
        usernameTF.addBottomLine()
        usernameTF.addLeftImage(imageName: "usernameIcon")
        usernameTF.setRightPaddingPoints(5)
        usernameTF.tintColor = .customGreen
        
        // PasswordTF
        passwordTF.addBottomLine()
        passwordTF.addLeftImage(imageName: "passwordIcon")
        passwordTF.setRightPaddingPoints(5)
        passwordTF.tintColor = .customGreen
    }
    
    func showHome() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        homeVC.modalTransitionStyle = .crossDissolve
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true)
    }
    
    @IBAction func loginClick(_ sender: UIButton) {

        guard let email = usernameTF.text, !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty else {
            
            showAlert(title: "Alert", message: "All fields are required !")
            return
        }
        showSpinnerInsideButton(sender: sender, activityIndicator: activityIndicator)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {
            result, error in
            
            guard error == nil else {
                self.showAlert(title: "Alert", message: "Bad credentials !")
                self.stopSpinner(sender: sender, activityIndicator: self.activityIndicator, buttonTitle: "Log in")
                print("error", error?.localizedDescription as Any)
                return
            }
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            self.stopSpinner(sender: sender, activityIndicator: self.activityIndicator, buttonTitle: "Log in")
            self.showHome()
        })
    }
}
