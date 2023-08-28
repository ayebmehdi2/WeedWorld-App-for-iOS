//
//  UserPostsCollectionViewCell.swift
//  weedworld
//
//  Created by Fares Ben amor on 29/1/2023.
//

import UIKit

class UserPostsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postImage: UIImageView! {
        didSet {
            postImage.layer.cornerRadius = 7
        }
    }
    @IBOutlet weak var textPost: UILabel!
    @IBOutlet weak var commentNbr: UIButton!
    @IBOutlet weak var likesNbr: UIButton!
    
}
