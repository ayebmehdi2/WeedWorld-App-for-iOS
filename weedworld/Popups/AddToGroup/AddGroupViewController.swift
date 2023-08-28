//
//  AddGroupViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 3/3/2023.
//

import UIKit
import FirebaseAuth

class AddGroupViewController: UIViewController {

    @IBOutlet weak var sendBtn: UIButton! {
        didSet {
            sendBtn.layer.cornerRadius = sendBtn.frame.height / 2
        }
    }
    @IBOutlet weak var lineView: UIView! {
        didSet {
            lineView.layer.cornerRadius = lineView.frame.height / 2
        }
    }
    @IBOutlet weak var addListTF: UITextField!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView! {
        didSet {
            bottomView.layer.cornerRadius = 30
            bottomView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    var passedUserUID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addListTF.addBottomLine()
        addNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomViewConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
       }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomViewConstraint.constant = keyboardSize.size.height
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomViewConstraint.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func createGroup() {
        if let text = addListTF.text {
            let group = ChatGroup.init(name: text, to: [passedUserUID], userId: Auth.auth().currentUser!.uid)
            
            group.save(completion: { success in
                if success {
                    self.addListTF.resignFirstResponder()
                    self.dismiss(animated: true)
                }
            })
        }
    }
    
    @IBAction func sendClick(_ sender: UIButton) {
        createGroup()
    }
    
    @IBAction func grayViewTap(_ sender: UITapGestureRecognizer) {
        addListTF.resignFirstResponder()
        bottomViewConstraint.constant = -250
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: true)
        })
    }
}
