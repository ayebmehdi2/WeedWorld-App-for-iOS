//
//  ChatTableViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 20/2/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView! {
        didSet {
            userImage.layer.cornerRadius = userImage.frame.height / 2
        }
    }
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var messageText: UILabel!
}
