//
//  CharGroupTableViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 3/3/2023.
//

import UIKit

class CharGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 10
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.shadowRadius = 2
            containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        }
    }
    @IBOutlet weak var groupName: UILabel!
}
