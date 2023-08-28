//
//  BusinessViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 20/3/2023.
//

import UIKit

class BusinessViewController: UIViewController {

    @IBOutlet weak var onlineStoreView: UIView! {
        didSet {
            onlineStoreView.layer.cornerRadius = 12
            onlineStoreView.layer.borderWidth = 0.5
            onlineStoreView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var localStoreView: UIView! {
        didSet {
            localStoreView.layer.cornerRadius = 12
            localStoreView.layer.borderWidth = 0.5
            localStoreView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var businessPageView: UIView! {
        didSet {
            businessPageView.layer.cornerRadius = 12
            businessPageView.layer.borderWidth = 0.5
            businessPageView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
    }
    
    @IBAction func onlineStoreClick(_ sender: UITapGestureRecognizer) {
        let onlineVC = OnlineStoreViewController(nibName: "OnlineStoreViewController", bundle: nil)
        navigationController?.pushViewController(onlineVC, animated: true)
    }
    
    @IBAction func localStoreClick(_ sender: UITapGestureRecognizer) {
        let localStoreVC = LocalStoreViewController(nibName: "LocalStoreViewController", bundle: nil)
        navigationController?.pushViewController(localStoreVC, animated: true)
    }
    
    @IBAction func businessPageClick(_ sender: UITapGestureRecognizer) {

    }
	
	@IBAction func menuClick(_ sender: UIBarButtonItem) {
		showSideMenu()
	}
}
