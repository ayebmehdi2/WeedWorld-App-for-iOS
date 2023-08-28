//
//  NewsDetailsTableViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 28/2/2023.
//

import UIKit

class NewsDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView! {
        didSet {
            userImage.layer.cornerRadius = userImage.frame.height / 2
        }
    }
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userComment: UILabel!
}
