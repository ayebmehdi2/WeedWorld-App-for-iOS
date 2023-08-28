//
//  RepostViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 2/3/2023.
//

import UIKit

class RepostViewController: UIViewController {

    @IBOutlet weak var contentView: UIView! {
        didSet {
            contentView.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var repostTitle: UILabel!
    @IBOutlet weak var yesBtn: UIButton! {
        didSet {
            yesBtn.layer.cornerRadius = 5
            yesBtn.layer.borderWidth = 0.5
            yesBtn.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    @IBOutlet weak var noBtn: UIButton! {
        didSet {
            noBtn.layer.cornerRadius = 5
        }
    }
    var repostTitleText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repostTitle.text = repostTitleText
    }
    
    @IBAction func yesClick(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func noClick(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
