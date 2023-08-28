//
//  EditOrDeleteDetailsViewController.swift
//  weedworld
//
//  Created by Fares Ben amor on 2/3/2023.
//

import UIKit

protocol EditOrDeleteDelegate: AnyObject {
    func deleteSelected()
    func editSelected()
}

class EditOrDeleteDetailsViewController: UIViewController {

    @IBOutlet weak var lineView: UIView! {
        didSet {
            lineView.layer.cornerRadius = lineView.frame.height / 2
        }
    }
    @IBOutlet weak var bottomView: UIView! {
        didSet {
            bottomView.layer.cornerRadius = 30
            bottomView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    weak var delegate: EditOrDeleteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomViewConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func garyViewTap(_ sender: UITapGestureRecognizer) {
        bottomViewConstraint.constant = -250
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: true)
        })
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
        dismiss(animated: true)
        delegate?.deleteSelected()
    }
    
    @IBAction func editClick(_ sender: UIButton) {
        dismiss(animated: true)
        delegate?.editSelected()
    }
}
