//
//  OnlineFriendsCollectionViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 20/2/2023.
//

import UIKit

class OnlineFriendsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var friendImage: UIImageView! {
        didSet {
            friendImage.layer.cornerRadius = friendImage.frame.height / 2
        }
    }
    @IBOutlet weak var greenDot: UIView! {
        didSet {
            greenDot.layer.cornerRadius = greenDot.frame.height / 2
        }
    }
}
