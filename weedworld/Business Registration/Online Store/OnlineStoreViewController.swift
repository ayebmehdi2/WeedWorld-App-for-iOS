//
//  OnlineStoreViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 23/3/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import UniformTypeIdentifiers

class OnlineStoreViewController: UIViewController {
    
    @IBOutlet weak var registerBtn: UIButton! {
        didSet {
            registerBtn.layer.cornerRadius = registerBtn.frame.height / 2
        }
    }
	@IBOutlet weak var businessNameTF: UITextField!
	@IBOutlet weak var phoneTF: UITextField!
	@IBOutlet weak var licenseNoTF: UITextField!
	@IBOutlet weak var websiteTF: UITextField!
	@IBOutlet weak var emailTF: UITextField!
	@IBOutlet weak var uploadPDFBtn: UIButton!
	@IBOutlet weak var userForBtn: UIButton!
	@IBOutlet weak var usedForStack: UIStackView!
	@IBOutlet weak var pdfStack: UIStackView!
	@IBOutlet weak var radioBtn: UIButton!
    @IBOutlet weak var bilingView: UIView! {
        didSet {
            bilingView.layer.cornerRadius = 12
            bilingView.layer.borderWidth = 0.5
            bilingView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var businessBtn: UIButton!
	let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
	var pdfFile: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Online Store"
        businessBtn.showsMenuAsPrimaryAction = true
		userForBtn.showsMenuAsPrimaryAction = true
        businessBtn.menu = createMenu()
		userForBtn.menu = createUsedForMenu()
		hideKeyboardWhenTappedAround()
    }
    
    func createMenu(actionTitle: String? = nil) -> UIMenu {
        
        let menu = UIMenu(title: "", children: [
            
            UIAction(title: "Cannabis store") { action in
                self.businessBtn.setTitle(action.title, for: .normal)
				self.businessBtn.setTitleColor(.black, for: .normal)
				self.pdfStack.isHidden = false
				self.usedForStack.isHidden = false
            },
            
            UIAction(title: "Delivery Service") { action in
                self.businessBtn.setTitle(action.title, for: .normal)
				self.businessBtn.setTitleColor(.black, for: .normal)
				self.pdfStack.isHidden = false
				self.usedForStack.isHidden = false
            },
            
            UIAction(title: "CBD/Hemp") { action in
                self.businessBtn.setTitle(action.title, for: .normal)
				self.businessBtn.setTitleColor(.black, for: .normal)
				self.pdfStack.isHidden = true
				self.usedForStack.isHidden = true
            },
            
            UIAction(title: "Hydrostore") { action in
                self.businessBtn.setTitle(action.title, for: .normal)
				self.businessBtn.setTitleColor(.black, for: .normal)
				self.pdfStack.isHidden = true
				self.usedForStack.isHidden = true
            },
            
            UIAction(title: "Doctor") { action in
                self.businessBtn.setTitle(action.title, for: .normal)
				self.businessBtn.setTitleColor(.black, for: .normal)
				self.pdfStack.isHidden = true
				self.usedForStack.isHidden = true
            },
            
            UIAction(title: "Other") { action in
                self.businessBtn.setTitle(action.title, for: .normal)
				self.businessBtn.setTitleColor(.black, for: .normal)
				self.pdfStack.isHidden = true
				self.usedForStack.isHidden = true
            }
        ])
        
        return menu
    }
	
	func createUsedForMenu(actionTitle: String? = nil) -> UIMenu {
		
		let menu = UIMenu(title: "", children: [
			
			UIAction(title: "Recreational") { action in
				self.userForBtn.setTitle(action.title, for: .normal)
				self.userForBtn.setTitleColor(.black, for: .normal)
			},
			
			UIAction(title: "Medicinal") { action in
				self.userForBtn.setTitle(action.title, for: .normal)
				self.userForBtn.setTitleColor(.black, for: .normal)
			},
		])
		
		return menu
	}
	
    @IBAction func radioClick(_ sender: UIButton) {
        sender.isSelected.toggle()

        if radioBtn.isSelected {
            radioBtn.tintColor = .customGreen
            radioBtn.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
			registerBtn.isEnabled = true
			registerBtn.backgroundColor = .customGreen
        }
        else {
            radioBtn.tintColor = .systemGray3
            radioBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
			registerBtn.isEnabled = false
			registerBtn.backgroundColor = .systemGray
        }
    }
	
	@IBAction func registerClick(_ sender: UIButton) {
		if businessBtn.title(for: .normal) == "Cannabis store" || businessBtn.title(for: .normal) == "Delivery Service" {
			saveStoreRegistration()
		}
		else if businessBtn.title(for: .normal) == "Business type" {
			showAlert(title: "Alert", message: "All fields are required !")
		}
		else {
			saveStoreOnly()
		}
	}
	
	func saveStoreOnly() {
		guard let businessType = businessBtn.title(for: .normal),
			  let businessName = businessNameTF.text,
			  let phone = phoneTF.text,
			  let licenseNo = licenseNoTF.text,
			  let email = emailTF.text,
			  let website = websiteTF.text else {
			showAlert(title: "Alert", message: "All fields are required !")
			return
		}
		showActivityIndicator(view: view, activityIndicator: activityIndicator)
		let store = StoreRegistration(businessName: businessName, businessType: businessType, emailAdress: email, license: licenseNo, phone: phone, userId: Auth.auth().currentUser!.uid, website: website)
		
		store.saveStoreOnly(completion: { success in
			if success {
				self.showAlert(title: "Success", message: "Your request is being processed.")
			}
			else {
				self.showAlert(title: "Error", message: "An error has occured.")
			}
			self.stopActivityIndicator(activityIndicator: self.activityIndicator)
		})
	}
	
	func saveStoreRegistration() {
		guard let businessType = businessBtn.title(for: .normal),
			  let usedFor = userForBtn.title(for: .normal),
			  let businessName = businessNameTF.text,
			  let phone = phoneTF.text,
			  let licenseNo = licenseNoTF.text,
			  let email = emailTF.text,
			  let website = websiteTF.text,
			  let pdfData = pdfFile else {
			showAlert(title: "Alert", message: "All fields are required !")
			return
		}
		showActivityIndicator(view: view, activityIndicator: activityIndicator)
		savePDFToFirestore(pdf: pdfData, completion: { url in
			guard let url = url else {
				self.showAlert(title: "Error", message: "An error has occured.")
				self.stopActivityIndicator(activityIndicator: self.activityIndicator)
				return
			}
			let storeRegistration = StoreRegistration(businessName: businessName, businessType: businessType, emailAdress: email, license: licenseNo, licensePDF: url, phone: phone, useFor: usedFor, userId: Auth.auth().currentUser!.uid, website: website)
			storeRegistration.saveResgistration(completion: { success in
				if success {
					self.showAlert(title: "Success", message: "Your request is being processed.")
				}
				else {
					self.showAlert(title: "Error", message: "An error has occured.")
				}
				self.stopActivityIndicator(activityIndicator: self.activityIndicator)
			})
		})
	}
	
	func savePDFToFirestore(pdf: Data, completion: @escaping (_ url: String?) -> Void) {
		let randomName = UUID()
		let storageRef = Storage.storage().reference().child("images/").child("storeRegistrationCollection").child(randomName.uuidString)
		let metaData = StorageMetadata()
		metaData.contentType = "application/pdf"
		
		storageRef.putData(pdf, metadata: metaData) { (metadata, error) in
			guard let error = error else {
				storageRef.downloadURL(completion: { (url, error) in
					guard let url = url else {
						print("Error", error!.localizedDescription)
						completion(nil)
						return
					}
					completion(url.absoluteString)
				})
				return
			}
			print("Error", error.localizedDescription)
			completion(nil)
		}
	}
	
	@IBAction func pdfStackTap(_ sender: UITapGestureRecognizer) {
		openFilesApp()
	}
	
	func openFilesApp() {
		let supportedTypes: [UTType] = [UTType.pdf]
		let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
		documentPicker.delegate = self
		documentPicker.modalPresentationStyle = .formSheet
		present(documentPicker, animated: true)
	}
}

extension OnlineStoreViewController: UIDocumentPickerDelegate {
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		
		for url in urls {
			guard url.startAccessingSecurityScopedResource() else {
				// Handle error here..
				return
			}
			
			defer { url.stopAccessingSecurityScopedResource() }

			do {
				let data = try Data(contentsOf: url)
				pdfFile = data
				uploadPDFBtn.setTitle(url.lastPathComponent, for: .normal)
			}
			catch let err {
				print("Error", err.localizedDescription)
			}
		}
	}
}
