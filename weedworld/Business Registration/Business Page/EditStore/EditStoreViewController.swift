//
//  EditStoreViewController.swift
//  weedworld
//
//  Created by Fares BEN AMOR on 29/05/2023.
//

import UIKit

class EditStoreViewController: UIViewController {

	@IBOutlet weak var emailTF: UITextField!
	@IBOutlet weak var phoneTF: UITextField!
	@IBOutlet weak var websiteTF: UITextField!
	@IBOutlet weak var fromTF: UITextField! {
		didSet {
			fromTF.layer.cornerRadius = 6
			fromTF.layer.borderWidth = 1
			fromTF.layer.borderColor = UIColor.systemGray.cgColor
			fromTF.addRightImage(imageName: "arrowBottom")
		}
	}
	@IBOutlet weak var selectDayTF: UITextField! {
		didSet {
			selectDayTF.layer.cornerRadius = 6
			selectDayTF.layer.borderWidth = 1
			selectDayTF.layer.borderColor = UIColor.systemGray.cgColor
			selectDayTF.addRightImage(imageName: "arrowBottom")
			selectDayTF.setLeftPaddingPoints(10)
		}
	}
	@IBOutlet weak var addBioTF: UITextField!
	@IBOutlet weak var toTF: UITextField! {
		didSet {
			toTF.layer.cornerRadius = 6
			toTF.layer.borderWidth = 1
			toTF.layer.borderColor = UIColor.systemGray.cgColor
			toTF.addRightImage(imageName: "arrowBottom")
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        fillDate()
    }
	
	func fillDate() {
		if let store = GlobalVar.userStore {
			phoneTF.text = store.phone
			emailTF.text = store.emailAddress
			websiteTF.text = store.website
			fromTF.text = store.fromTime ?? "8:00 AM"
			toTF.text = store.toTime ?? "9:00 AM"
		}
	}
	
	@IBAction func backButtonClick(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
}
