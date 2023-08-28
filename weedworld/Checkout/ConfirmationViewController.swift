//
//  ConfirmationViewController.swift
//  weedworld
//
//  Created by Mac on 15/7/2023.
//

import UIKit

class ConfirmationViewController: UIViewController {

    var image: UIImage?
    var store: LocalStore?
    
    @IBOutlet weak var qrCodeImage: UIImageView!
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.layer.cornerRadius = 25
            doneButton.backgroundColor = UIColor(red: 0.21, green: 0.7, blue: 0.31, alpha: 1)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        qrCodeImage.image = image
        setupNavBar()
    }

    func setupNavBar() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.89, blue: 0.78, alpha: 1)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: store?.businessName, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }

    @IBAction func doneAction(_ sender: Any) {
//        let sb = UIStoryboard(name: "Orders", bundle: nil)
//        let vc = sb.instantiateViewController(withIdentifier: "OrdersVC") as! UINavigationController
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        let orderVC = OrdersListViewController()
        let navVC = UINavigationController(rootViewController: orderVC)
        navVC.modalTransitionStyle = .crossDissolve
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}
