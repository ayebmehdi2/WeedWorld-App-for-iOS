//
//  ReceiverTableViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 11/3/2023.
//

import UIKit

class ReceiverTableViewCell: UITableViewCell {

    @IBOutlet weak var imageReceiver: UIImageView! {
        didSet {
            imageReceiver.layer.cornerRadius = imageReceiver.frame.width / 2
        }
    }
    @IBOutlet weak var emojiReveiver: UIImageView!
    @IBOutlet weak var bubleViewReceiver: UIView! {
        didSet {
            bubleViewReceiver.layer.cornerRadius = 13
            bubleViewReceiver.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var texteReceiver: UILabel!
    @IBOutlet weak var contentStackWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        texteReceiver.numberOfLines = 0
        texteReceiver.lineBreakMode = .byWordWrapping
        texteReceiver.setContentHuggingPriority(.required, for: .vertical)
    }
}
