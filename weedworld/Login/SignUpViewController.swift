//
//  SignUpViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 14/1/2023.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var birthdayTF: UITextField!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton! {
        didSet {
            signUpBtn.layer.cornerRadius = signUpBtn.frame.height / 2
        }
    }
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var gender: String = "Male"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationCenterObservers()
        hideKeyboardWhenTappedAround()
        setupTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if birthdayTF.isFirstResponder {
                if view.frame.origin.y == 0 {
                    view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func setupTextFields() {
        
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
        
        // EmailTF
        emailTF.addBottomLine()
        emailTF.addLeftImage(imageName: "emailIcon")
        emailTF.setRightPaddingPoints(5)
        emailTF.tintColor = .customGreen
        
        // BirthdayTF
        birthdayTF.addBottomLine()
        birthdayTF.addLeftImage(imageName: "calendar")
        birthdayTF.setRightPaddingPoints(5)
        birthdayTF.tintColor = .customGreen
    }
    
    func selectBtn(button: UIButton) {
        button.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 18)!
        button.setTitleColor(.customGreen, for: .normal)
    }
    
    func unselectBtns(buttons: [UIButton]) {
        for button in buttons {
            button.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 18)!
            button.setTitleColor(.customGray, for: .normal)
        }
    }
    
    @IBAction func maleBtnClick(_ sender: UIButton) {
        selectBtn(button: sender)
        unselectBtns(buttons: [femaleBtn, otherBtn])
        gender = sender.title(for: .normal) ?? "Male"
    }
    
    @IBAction func femaleBtnClick(_ sender: UIButton) {
        selectBtn(button: sender)
        unselectBtns(buttons: [maleBtn, otherBtn])
        gender = sender.title(for: .normal) ?? "Male"
    }
    
    @IBAction func otherBtnClick(_ sender: UIButton) {
        selectBtn(button: sender)
        unselectBtns(buttons: [maleBtn, femaleBtn])
        gender = sender.title(for: .normal) ?? "Male"
    }
    
    @IBAction func signupClick(_ sender: UIButton) {
        signUp(sender: sender)
    }
    
    func showHome() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        homeVC.modalTransitionStyle = .crossDissolve
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true)
    }
    
    func signUp(sender: UIButton) {

        guard let email = emailTF.text, !email.isEmpty,
            let password = passwordTF.text, !password.isEmpty,
            let username = usernameTF.text, !username.isEmpty,
            let phone = phoneTF.text, !phone.isEmpty,
            let dateBirth = birthdayTF.text, !dateBirth.isEmpty else {
            
            showAlert(title: "Alert", message: "All fields are required !")
            return
        }
        sender.isEnabled = false
        showSpinnerInsideButton(sender: sender, activityIndicator: activityIndicator)
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {
           [unowned self] (result, error) in
            
            sender.isEnabled = true
            
            guard error == nil else {
                
                if error!.localizedDescription == "The email address is already in use by another account." {
                    showAlert(title: "Alert", message: error!.localizedDescription)
                }
                else if error!.localizedDescription == "The email address is badly formatted." {
                    showAlert(title: "Alert", message: error!.localizedDescription)
                }
                
                else if error!.localizedDescription == "The password must be 6 characters long or more." {
                    showAlert(title: "Alert", message: error!.localizedDescription)
                }
                else {
                    showAlert(title: "Alert", message: "An error has occured, please try later.")
                }
                
                print("Error", error!.localizedDescription)
                self.stopSpinner(sender: sender, activityIndicator: self.activityIndicator, buttonTitle: "Sign up")
                
                return
            }
            let user = User.init(uid: Auth.auth().currentUser!.uid, username: username, email: email, phone: phone, birthday: dateBirth, gender: gender)
            
            user.save(completion: { (success) in
                if success {
                    let alert = UIAlertController(title: "Success !", message: "Your account has been successfully added !", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.showHome()
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
                else {
                    self.showAlert(title: "Alert", message: "An error has occured, please try later.")
                }
                self.stopSpinner(sender: sender, activityIndicator: self.activityIndicator, buttonTitle: "Sign up")
            })
        })
    }
}

extension SignUpViewController: UITextFieldDelegate, DatePickerPopupDelegate {
            
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == birthdayTF {
            showDatePicker()
            return false
        }
        return true
    }
    
    func showDatePicker() {
        let dateVC = DatePickerPopupViewController(nibName: "DatePickerPopupViewController", bundle: nil)
        dateVC.modalPresentationStyle = .overCurrentContext
        dateVC.modalTransitionStyle = .crossDissolve
        dateVC.delegate = self
        present(dateVC, animated: false)
    }
    
    func getSelectedDate(date: String) {
        birthdayTF.text = date
    }
    
    func viewDismissed() {
        view.frame.origin.y = 0
    }
}
