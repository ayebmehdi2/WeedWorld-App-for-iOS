//
//  SenderTableViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 11/3/2023.
//

import UIKit

class SenderTableViewCell: UITableViewCell {

    @IBOutlet weak var emojiSender: UIImageView!
    @IBOutlet weak var textSender: UILabel!
    @IBOutlet weak var imageSender: UIImageView! {
        didSet {
            imageSender.layer.cornerRadius = imageSender.frame.width / 2
        }
    }
    @IBOutlet weak var bubleViewSender: UIView! {
        didSet {
            bubleViewSender.layer.cornerRadius = 13
            bubleViewSender.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var contentSenderStackWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textSender.numberOfLines = 0
        textSender.lineBreakMode = .byWordWrapping
        textSender.setContentHuggingPriority(.required, for: .vertical)
    }
}
