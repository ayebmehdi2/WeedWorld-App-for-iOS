//
//  MenuTableViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 25/1/2023.
//

import UIKit
import FirebaseAuth
import Kingfisher

class MenuTableViewController: UITableViewController {
    
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet weak var userProfileImage: UIImageView! {
        didSet {
            userProfileImage.layer.cornerRadius = userProfileImage.frame.height / 2
        }
    }
	@IBOutlet weak var cartProductNumbers: UIButton! {
		didSet {
			cartProductNumbers.layer.cornerRadius = 5
		}
	}
	@IBOutlet weak var storeSectionStackView: UIStackView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var storeImage: UIImageView! {
		didSet {
			storeImage.layer.cornerRadius = storeImage.frame.height / 2
		}
	}
	@IBOutlet weak var storeName: UILabel!
	let userDef = UserDefaults.standard
	
	override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fillUserData()
    }
    
    func setupTableView() {
        menuTableView.layer.cornerRadius = 25
        menuTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        menuTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    @IBAction func userImageTap(_ sender: UITapGestureRecognizer) {
        showUserProfile()
    }
    
    @IBAction func userNameTap(_ sender: UITapGestureRecognizer) {
        showUserProfile()
    }
    
    @IBAction func qrCodeProfileClick(_ sender: UIButton) {
        showQRCode()
    }
    
	@IBAction func storeStackClick(_ sender: UITapGestureRecognizer) {
		showBusinessPage()
	}
	
	func fillUserData() {
        if let user = GlobalVar.user {
            userNameLabel.text = user.username.capitalized
            if let photo = user.profilePhoto {
                userProfileImage.kf.setImage(with: URL(string: photo), placeholder: UIImage(named: "placeholder"), options: [])
            }
        }
		
		if let store = GlobalVar.userStore {
			storeName.text = store.businessName?.capitalized
			if let photo = store.photo {
				storeImage.kf.setImage(with: URL(string: photo), placeholder: UIImage(named: "placeholder"), options: [])
			}
		}
		else {
			// Hide the store section...
			storeSectionStackView.isHidden = true
			menuTableView.tableHeaderView?.frame.size.height -= storeSectionStackView.frame.height + 40 // 40 is content stack padding
		}
		
		// Add number of products
		if let products = userDef.data(forKey: "products") {
			do {
				let productsDecoded = try JSONDecoder().decode([Product].self, from: products)
				cartProductNumbers.setTitle(productsDecoded.count.description, for: .normal)
				if productsDecoded.isEmpty {
					cartProductNumbers.isHidden = true
				}
			} catch let err {
				print("Error decoding ", err.localizedDescription)
			}
		} else {
			cartProductNumbers.isHidden = true
		}
    }
    
    func showQRCode() {
        let qrVC = QRCodeViewController(nibName: "QRCodeViewController", bundle: nil)
        qrVC.modalTransitionStyle = .crossDissolve
        qrVC.modalPresentationStyle = .overFullScreen
        qrVC.QRCodeString = Auth.auth().currentUser!.uid
        present(qrVC, animated: true)
    }
    
    func showUserProfile() {
        let sb = UIStoryboard(name: "UserProfile", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        profileVC.modalTransitionStyle = .crossDissolve
        profileVC.modalPresentationStyle = .fullScreen
        present(profileVC, animated: true)
    }
	
	func showBusinessPage() {
		let businessPage = BusinessPageViewController(nibName: "BusinessPageViewController", bundle: nil)
		businessPage.passedStore = GlobalVar.userStore
		businessPage.modalTransitionStyle = .crossDissolve
		businessPage.modalPresentationStyle = .fullScreen
		present(businessPage, animated: true)
	}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let sb = UIStoryboard(name: "Home", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
		if indexPath.row == 2 {
			let sb = UIStoryboard(name: "Market", bundle: nil)
			let vc = sb.instantiateViewController(withIdentifier: "marketVC") as! UINavigationController
			vc.modalTransitionStyle = .crossDissolve
			vc.modalPresentationStyle = .fullScreen
			present(vc, animated: true)
		}
		if indexPath.row == 3 {
            let orderVC = OrdersListViewController()
            let navVC = UINavigationController(rootViewController: orderVC)
//			let sb = UIStoryboard(name: "Orders", bundle: nil)
//			let vc = sb.instantiateViewController(withIdentifier: "OrdersVC") as! UINavigationController
            navVC.modalTransitionStyle = .crossDissolve
            navVC.modalPresentationStyle = .fullScreen
			present(navVC, animated: true)
		}
		if indexPath.row == 4 {
			let sb = UIStoryboard(name: "Cards", bundle: nil)
			let vc = sb.instantiateViewController(withIdentifier: "CardsVC") as! UINavigationController
			vc.modalTransitionStyle = .crossDissolve
			vc.modalPresentationStyle = .fullScreen
			present(vc, animated: true)
		}
        if indexPath.row == 6 {
            let sb = UIStoryboard(name: "Business", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "businessNC") as! UINavigationController
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if GlobalVar.userStore != nil {
			return indexPath.row == 6 ? 0 : 60
		}
		else {
			return 60
		}
	}
}
