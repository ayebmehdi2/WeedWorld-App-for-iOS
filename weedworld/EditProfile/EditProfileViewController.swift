//
//  EditProfileViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 17/1/2023.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var completeLabel: UILabel!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var wwIDTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var dateBirthTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupCompleteLabel()
        hideKeyboardWhenTappedAround()
    }
    
    func setupTextFields() {
        
        // UsernameTF
        usernameTF.addBottomLineEdit()
        usernameTF.addLeftImage(imageName: "userEditIcon")
        usernameTF.tintColor = .customGreen
        
        // wwIDTF
        wwIDTF.addBottomLineEdit()
        wwIDTF.setRightPaddingPoints(5)
        wwIDTF.tintColor = .customGreen
        
        // genderTF
        genderTF.addBottomLineEdit()
        genderTF.addLeftImage(imageName: "female")
        genderTF.addRightImage(imageName: "genderEye")
        genderTF.tintColor = .customGreen
        
        // PasswordTF
        passwordTF.addBottomLineEdit()
        passwordTF.addLeftImage(imageName: "passwordEdit")
        passwordTF.tintColor = .customGreen
        
        // dateBirthTF
        dateBirthTF.addBottomLineEdit()
        dateBirthTF.tintColor = .customGreen
        
        // AgeTF
        ageTF.addBottomLineEdit()
        ageTF.addRightImage(imageName: "grayEye")
        ageTF.tintColor = .customGreen
        
        // LocationTF
        locationTF.addBottomLineEdit()
        locationTF.addRightImage(imageName: "grayEye")
        locationTF.tintColor = .customGreen
    }
    
    func setupCompleteLabel() {
        let attrs1 = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.customRed2]
        let attrs2 = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.customGray]
        let attributedString1 = NSMutableAttributedString(string: "42% ", attributes: attrs1)
        let attributedString2 = NSMutableAttributedString(string: "complete", attributes :attrs2)
        attributedString1.append(attributedString2)
        completeLabel.attributedText = attributedString1
    }
}
